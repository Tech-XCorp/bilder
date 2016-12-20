#!/bin/bash
#
# Build information for opencascade
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in opencascade_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/opencascade_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOpenCascadeNonTriggerVars() {
  OPENCASCADE_UMASK=002
}
setOpenCascadeNonTriggerVars

######################################################################
#
# Launch opencascade builds.
#
######################################################################

#
# Build OPENCASCADE
#
buildOpenCascade() {

# Remove old tpaviot repo to move to ours
  if (cd $PROJECT_DIR/opencascade 2>/dev/null; git remote -v | grep "^origin\t" | grep -q tpaviot); then
    techo "NOTE: [$FUNCNAME] Removing clone of tpaviot repo."
    cmd="rm -rf $PROJECT_DIR/opencascade"
    techo "$cmd"
    eval "$cmd"
  fi

# Get opencascade from repo and remove any detritus
  updateRepo opencascade
  rm -f $PROJECT_DIR/opencascade/CMakeLists.txt.{orig,rej}

# If no subdir, done.
  if ! test -d $PROJECT_DIR/opencascade; then
    techo "WARNING: opencascade dir not found. Building from package."
  fi

# Get opencascade
  cd $PROJECT_DIR
  local OPENCASCADE_ADDL_ARGS=
  local OPENCASCADE_INSTALL_DIR=
  if test -d opencascade; then
    getVersion opencascade
    local patchfile=$BILDER_DIR/patches/opencascade-${OPENCASCADE_BLDRVERSION}.patch
    if ! test -e $patchfile && $BUILD_EXPERIMENTAL; then
      patchfile=$BILDER_DIR/patches/opencascade-exp.patch
    fi
    if test -e $patchfile; then
      cmd="(cd $PROJECT_DIR/opencascade; patch -N -p1 <$patchfile)"
      techo "$cmd"
      eval "$cmd"
    fi
    if ! bilderPreconfig opencascade; then
      return 1
    fi
    OPENCASCADE_INSTALL_DIR="$BLDR_INSTALL_DIR/opencascade-$OPENCASCADE_BLDRVERSION-$OPENCASCADE_BUILD"
    techo "NOTE: opencascade git repo found."
  else
    if ! bilderUnpack opencascade; then
      return 1
    fi
    OPENCASCADE_INSTALL_DIR="$CONTRIB_DIR/opencascade-$OPENCASCADE_BLDRVERSION-$OPENCASCADE_BUILD"
  fi
  OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DOPENCASCADE_INSTALL_PREFIX:PATH=$OPENCASCADE_INSTALL_DIR -DCMAKE_INSTALL_NAME_DIR:PATH=$OPENCASCADE_INSTALL_DIR/lib -DOPENCASCADE_MULTITHREADED_BUILD:BOOL=FALSE -DOPENCASCADE_TESTING:BOOL=TRUE"

# Find freetype
  if test -z "$FREETYPE_PYCST_DIR" -a -z "$FREETYPE_PYCSH_DIR"; then
    source $BILDER_DIR/packages/freetype_aux.sh
    findFreetype
  fi

# Set other args, env
  local OPENCASCADE_ENV=
# Disabling X11 prevents build of TKMeshVS, needed for salomesh in freecad.
  # OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DOPENCASCADE_DISABLE_X11:BOOL=TRUE"
  local shlinkflags=
  case `uname` in
    CYGWIN*)
      local depdir=
      if test -n "$FREETYPE_PYCST_DIR"; then
        depdir=`cygpath -am $FREETYPE_PYCST_DIR`
        OPENCASCADE_ENV="FREETYPE_DIR='$depdir'"
      fi
      if test -n "$LIBPNG_PYCSH_DIR"; then
        depdir=`cygpath -am $LIBPNG_PYCSH_DIR`
        OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DPNG_PNG_INCLUDE_DIR='${depdir}/include' -DPNG_LIBRARY='${depdir}/lib/libpng_static.lib'"
      fi
# Bilder does not use opencascade bundle (precompiled dependencies), so cannot install
      OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DOPENCASCADE_BUNDLE_AUTOINSTALL:BOOL=FALSE"
# Not using precompiled headers allows use of jom on Windows.
# This may allow removal of pch's just before build.
      OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DOPENCASCADE_USE_PCH:BOOL=FALSE"
# Below not needed, but it is true.
      # OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DOPENCASCADE_USE_BUNDLE:BOOL=FALSE"
      ;;
    Darwin)
      if test -n "$FREETYPE_PYCSH_DIR"; then
        OPENCASCADE_ENV="FREETYPE_DIR='$FREETYPE_PYCSH_DIR'"
      fi
      OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS'"
      ;;
    Linux)
      local shrpath=XORIGIN:XORIGIN/../lib
      if test -n "$FREETYPE_PYCSH_DIR" -a "$FREETYPE_PYCSH_DIR" != /usr; then
        shrpath="$shrpath:$FREETYPE_PYCSH_DIR/lib"
      fi
      shlinkflags="-Wl,-rpath,$shrpath"
      OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
      ;;
  esac
  if test -n "$shlinkflags"; then
    OPENCASCADE_ADDL_ARGS="$OPENCASCADE_ADDL_ARGS -DCMAKE_SHARED_LINKER_FLAGS:STRING='$shlinkflags'"
  fi

# Configure and build
  local otherargsvar=`genbashvar OPENCASCADE_${QT_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`
  if bilderConfig opencascade $OPENCASCADE_BUILD "-DOPENCASCADE_INSTALL_INCLUDE_DIR:STRING=include $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $OPENCASCADE_ADDL_ARGS $otherargsval" "" "$OPENCASCADE_ENV"; then
# On windows, prepare the pre-compiled headers
    if [[ `uname` =~ CYGWIN ]]; then
      local precompiledout=$BUILD_DIR/opencascade/$OPENCASCADE_BUILD/precompiled.out
      rm -f $precompiledout
      for i in $BUILD_DIR/opencascade/$OPENCASCADE_BUILD/adm/cmake/*; do
        cmd="(cd $i; jom Precompiled.obj >>$precompiledout 2>&1)"
        techo "$cmd"
        eval "$cmd"
      done
    fi
# Do not do make clean, as that undoes the making of precompiled headers
    bilderBuild -k opencascade $OPENCASCADE_BUILD "$OPENCASCADE_MAKEJ_ARGS" "$OPENCASCADE_ENV"
  fi

}

######################################################################
#
# Test opencascade
#
######################################################################

testOpenCascade() {
  techo "Not testing opencascade."
}

######################################################################
#
# Install opencascade
#
######################################################################

installOpenCascade() {

  if bilderInstall opencascade $OPENCASCADE_BUILD; then

# Fixup library references removing references to full paths
# to install directory for both OPENCASCADE libs and the freetype lib.
# Also install freetype lib with OPENCASCADE.
    local opencascadelibdir="$BLDR_INSTALL_DIR/opencascade-$OPENCASCADE_BLDRVERSION-$OPENCASCADE_BUILD/lib"
    case `uname` in
      CYGWIN*)
        ;;
      Darwin)
        ;;
      Linux)
        ;;
    esac

  fi

}


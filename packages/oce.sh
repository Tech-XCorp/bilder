#!/bin/bash
#
# Build information for oce
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in oce_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/oce_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOceNonTriggerVars() {
  OCE_UMASK=002
}
setOceNonTriggerVars

######################################################################
#
# Launch oce builds.
#
######################################################################

#
# Build OCE
#
buildOce() {

# Remove old tpaviot repo to move to ours
  if (cd $PROJECT_DIR/oce 2>/dev/null; git remote -v | grep "^origin\t" | grep -q tpaviot); then
    techo "NOTE: [$FUNCNAME] Removing clone of tpaviot repo."
    cmd="rm -rf $PROJECT_DIR/oce"
    techo "$cmd"
    eval "$cmd"
  fi

# Get oce from repo and remove any detritus
  updateRepo oce
  rm -f $PROJECT_DIR/oce/CMakeLists.txt.{orig,rej}

# If no subdir, done.
  if ! test -d $PROJECT_DIR/oce; then
    techo "WARNING: oce dir not found. Building from package."
  fi

# Get oce
  cd $PROJECT_DIR
  local OCE_ADDL_ARGS=
  local OCE_INSTALL_DIR=
  if test -d oce; then
    getVersion oce
    local patchfile=$BILDER_DIR/patches/oce-${OCE_BLDRVERSION}.patch
    if ! test -e $patchfile && $BUILD_EXPERIMENTAL; then
      patchfile=$BILDER_DIR/patches/oce-exp.patch
    fi
    if test -e $patchfile; then
      cmd="(cd $PROJECT_DIR/oce; patch -N -p1 <$patchfile)"
      techo "$cmd"
      eval "$cmd"
    fi
    if ! bilderPreconfig oce; then
      return 1
    fi
    OCE_INSTALL_DIR="$BLDR_INSTALL_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD"
    techo "NOTE: oce git repo found."
  else
    if ! bilderUnpack oce; then
      return 1
    fi
    OCE_INSTALL_DIR="$CONTRIB_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD"
  fi
  OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_INSTALL_PREFIX:PATH=$OCE_INSTALL_DIR -DCMAKE_INSTALL_NAME_DIR:PATH=$OCE_INSTALL_DIR/lib -DOCE_MULTITHREADED_BUILD:BOOL=FALSE -DOCE_TESTING:BOOL=TRUE"

# Find freetype
  if test -z "$FREETYPE_PYCST_DIR" -a -z "$FREETYPE_PYCSH_DIR"; then
    source $BILDER_DIR/packages/freetype_aux.sh
    findFreetype
  fi

# Set other args, env
  local OCE_ENV=
# Disabling X11 prevents build of TKMeshVS, needed for salomesh in freecad.
  # OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_DISABLE_X11:BOOL=TRUE"
  local shlinkflags=
  case `uname` in
    CYGWIN*)
      local depdir=
      if test -n "$FREETYPE_PYCST_DIR"; then
        depdir=`cypath -am $FREETYPE_PYCST_DIR'`
        OCE_ENV="FREETYPE_DIR='$depdir'"
      fi
      if test -n "$LIBPNG_PYCSH_DIR"; then
        depdir=`cypath -am $LIBPNG_PYCSH_DIR'`
        OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DPNG_PNG_INCLUDE_DIR='${depdir}/include' -DPNG_LIBRARY='${depdir}/lib/libpng_static.lib'"
      fi
# Bilder does not use oce bundle (precompiled dependencies), so cannot install
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_BUNDLE_AUTOINSTALL:BOOL=FALSE"
# Not using precompiled headers allows use of jom on Windows.
# This may allow removal of pch's just before build.
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_USE_PCH:BOOL=FALSE"
# Below not needed, but it is true.
      # OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DOCE_USE_BUNDLE:BOOL=FALSE"
      ;;
    Darwin)
      if test -n "$FREETYPE_PYCSH_DIR"; then
        OCE_ENV="FREETYPE_DIR='$FREETYPE_PYCSH_DIR'"
      fi
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DCMAKE_CXX_FLAGS='$PYC_CXXFLAGS'"
      ;;
    Linux)
      local shrpath=XORIGIN:XORIGIN/../lib
      if test -n "$FREETYPE_PYCSH_DIR" -a "$FREETYPE_PYCSH_DIR" != /usr; then
        shrpath="$shrpath:$FREETYPE_PYCSH_DIR/lib"
      fi
      shlinkflags="-Wl,-rpath,$shrpath"
      OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
      ;;
  esac
  if test -n "$shlinkflags"; then
    OCE_ADDL_ARGS="$OCE_ADDL_ARGS -DCMAKE_SHARED_LINKER_FLAGS:STRING='$shlinkflags'"
  fi

# Configure and build
  local otherargsvar=`genbashvar OCE_${QT_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`
  if bilderConfig oce $OCE_BUILD "-DOCE_INSTALL_INCLUDE_DIR:STRING=include $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $OCE_ADDL_ARGS $otherargsval" "" "$OCE_ENV"; then
# On windows, prepare the pre-compiled headers
    if [[ `uname` =~ CYGWIN ]]; then
      local precompiledout=$BUILD_DIR/oce/$OCE_BUILD/precompiled.out
      rm -f $precompiledout
      for i in $BUILD_DIR/oce/$OCE_BUILD/adm/cmake/*; do
        cmd="(cd $i; jom Precompiled.obj >>$precompiledout 2>&1)"
        techo "$cmd"
        eval "$cmd"
      done
    fi
# Do not do make clean, as that undoes the making of precompiled headers
    bilderBuild -k oce $OCE_BUILD "$OCE_MAKEJ_ARGS" "$OCE_ENV"
  fi

}

######################################################################
#
# Test oce
#
######################################################################

testOce() {
  techo "Not testing oce."
}

######################################################################
#
# Install oce
#
######################################################################

installOce() {

  if bilderInstall oce $OCE_BUILD; then

# Fixup library references removing references to full paths
# to install directory for both OCE libs and the freetype lib.
# Also install freetype lib with OCE.
    local ocelibdir="$BLDR_INSTALL_DIR/oce-$OCE_BLDRVERSION-$OCE_BUILD/lib"
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


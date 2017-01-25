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

buildOpenCascade() {
# Unpack
  if ! bilderUnpack opencascade; then
    return 1
  fi
  OPENCASCADE_BUILD=pycsh
  OPENCASCADE_INSTALL_DIR="$CONTRIB_DIR/opencascade-$OPENCASCADE_BLDRVERSION-$OPENCASCADE_BUILD"

# Find freetype
  if test -z "$FREETYPE_PYCST_DIR" -a -z "$FREETYPE_PYCSH_DIR"; then
    source $BILDER_DIR/packages/freetype_aux.sh
    findFreetype
  fi

# Set other args, env
  local OPENCASCADE_ENV=
# Disabling X11 prevents build of TKMeshVS, needed for salomesh in freecad.
  # OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DOPENCASCADE_DISABLE_X11:BOOL=TRUE"
  local shlinkflags=
  case `uname` in
    CYGWIN*)
      local depdir=
      if test -n "$FREETYPE_PYCST_DIR"; then
        depdir=`cygpath -am $FREETYPE_PYCST_DIR`
        OPENCASCADE_ENV="FREETYPE_DIR='$depdir'"
      fi
      if test -n "$LIBPNG_PYCSH_DIR"; then
        # depdir=`cygpath -am $LIBPNG_PYCSH_DIR`
        shlinkflags="/LIBPATH $LIBPNG_PYCSH_DIR/lib/libpng_static.lib"
      fi
      if test -n "$CMAKE_ZLIB_SERMD_LIBDIR"; then
        shlinkflags="$shlinkflags /LIBPATH $CMAKE_ZLIB_SERMD_LIBDIR/zlib.lib"
      fi
      OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DCMAKE_SHARED_LINKER_FLAGS:STRING='$shlinkflags'"
      ;;
    Darwin)
      OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DCMAKE_INSTALL_NAME_DIR:PATH='$OPENCASCADE_INSTALL_DIR/lib'"
      ;;
    Linux)
      local shrpath="XORIGIN:XORIGIN/../lib:$OPENCASCADE_INSTALL_DIR/lib"
# No need for absolute as will set relative, but gives more room for chrpath.
      if test -n "$FREETYPE_PYCSH_DIR" -a "$FREETYPE_PYCSH_DIR" != /usr; then
        shrpath="$shrpath:$FREETYPE_PYCSH_DIR/lib"
      fi
      # shlinkflags="-Wl,-rpath,$shrpath"
# Below gets rpath correct (origin stuff, install dir) upon installation.
      # OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DCMAKE_SKIP_RPATH:BOOL=TRUE -DCMAKE_SHARED_LINKER_FLAGS:STRING='$shlinkflags'"
# Below also gets it right and is simpler.
      OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH='$shrpath'"
      ;;
  esac

# Set additional flags
# Disable draw module, as it brings difficulties with the tcl/tk version
  OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DBUILD_MODULE_Draw=FALSE"
  if test -n "$FREETYPE_PYCSH_DIR"; then
    OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -D3RDPARTY_FREETYPE_DIR='$FREETYPE_PYCSH_DIR'"
  fi

# Build
  if bilderConfig opencascade $OPENCASCADE_BUILD "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $OPENCASCADE_PYCSH_ADDL_ARGS $OPENCASCADE_PYCSH_OTHER_ARGS"; then
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

# Set umask to allow only group to use
installOpenCascade() {
  if bilderInstallAll opencascade; then
    case `uname` in
      Linux)
        rp=`chrpath -l $OPENCASCADE_INSTALL_DIR/lib/libTKStd.so | sed -e 's/^.*RPATH=//' -e 's/XORIGIN/$ORIGIN/g'`
        for lib in $OPENCASCADE_INSTALL_DIR/lib/lib*.so; do
          chrpath -r "$rp" $lib
        done
        ;;
    esac
  fi
}


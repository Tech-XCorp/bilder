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
        depdir=`cygpath -am $LIBPNG_PYCSH_DIR`
        OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DPNG_PNG_INCLUDE_DIR='${depdir}/include' -DPNG_LIBRARY='${depdir}/lib/libpng_static.lib'"
      fi
# Bilder does not use oce bundle (precompiled dependencies), so cannot install
      OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DOPENCASCADE_BUNDLE_AUTOINSTALL:BOOL=FALSE"
# Not using precompiled headers allows use of jom on Windows.
# This may allow removal of pch's just before build.
      OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DOPENCASCADE_USE_PCH:BOOL=FALSE"
      ;;
    Darwin)
      OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DCMAKE_INSTALL_NAME_DIR:PATH='$OPENCASCADE_INSTALL_DIR/lib'"
      ;;
    Linux)
      local shrpath="XORIGIN:XORIGIN/../lib:$OPENCASCADE_INSTALL_DIR/lib"
      if test -n "$FREETYPE_PYCSH_DIR" -a "$FREETYPE_PYCSH_DIR" != /usr; then
        shrpath="$shrpath:$FREETYPE_PYCSH_DIR/lib"
      fi
      shlinkflags="-Wl,-rpath,$shrpath"
      OPENCASCADE_PYCSH_ADDL_ARGS="$OPENCASCADE_PYCSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE -DCMAKE_SHARED_LINKER_FLAGS:STRING='$shlinkflags'"
      ;;
  esac

# Set additional flags
# Turn off draw module, as it brings difficulties with the tcl/tk version
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
  bilderInstallAll opencascade
# On linux, fix rpath?
}


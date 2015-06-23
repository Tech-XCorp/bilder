#!/bin/bash
#
# Build information for python
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in python_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/python_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPythonNonTriggerVars() {
  PYTHON_UMASK=002
}
setPythonNonTriggerVars

######################################################################
#
# Launch python builds.
#
######################################################################

buildPython() {

# Get python from either repo or unpack it
  local res=
  echo "VISUALSTUDIO_VERSION = $VISUALSTUDIO_VERSION"
  if test -n "$VISUALSTUDIO_VERSION" -a "$VISUALSTUDIO_VERSION" -ge 12; then
    updateRepo python
    getVersion python
    bilderPreconfig python
    res=$?
  else
    bilderUnpack Python
    res=$?
  fi
  if test $res != 0; then
    return
  fi

# Set up flags
  if declare -f setCc4pyAddlLdflags 1>/dev/null 2>&1; then
    setCc4pyAddlLdflags
  fi
  local pyldflags="$PYCSH_ADDL_LDFLAGS"
  local pycppflags=
  case `uname` in
    CYGWIN*)
      PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS -DBUILD_SHARED=ON -DBUILD_STATIC=OFF -DZLIB_LIBRARY='$CMAKE_ZLIB_SERSH_LIBDIR/zlib.lib' -DZLIB_INCLUDE_DIR='$CMAKE_ZLIB_SERSH_INCDIR'"
# Also need BZIP2_LIBRARIES
# Remove old build directory to repatch
      rm -rf $BUILD_DIR/Python/*
      ;;
    Linux)
# Ensure python can find its own library and any libraries linked into contrib
      pyldflags="$pyldflags -Wl,-rpath,${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$FORPYTHON_SHARED_BUILD/lib -L$CONTRIB_DIR/lib -Wl,-rpath,$CONTRIB_DIR/lib -Wl,--export-dynamic"
      if cd $CONTRIB_DIR/sqlite-$FORPYTHON_SHARED_BUILD; then
        local preswd=`pwd -P`
        pyldflags="$pyldflags -L$preswd/lib"
        pycppflags="-I$preswd/include"
      fi
      PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS CC='$PYC_CC $PYC_CFLAGS' CFLAGSFORSHARED=-fPIC --enable-shared"
      case $PYTHON_BLDRVERSION in
        2.6.*) ;;  # enable-unicode fails on 2.6.5
        2.7.*) PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS --enable-unicode=ucs4";;
      esac
      ;;
  esac
  if test -n "$pyldflags"; then
    PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS LDFLAGS='$pyldflags'"
  fi
  if test -n "$pycppflags"; then
    PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS CPPFLAGS='$pycppflags'"
  fi

# just --enable-shared gives errors:
# Failed to find the necessary bits to build these modules:
#   _tkinter bsddb185 dl imageop sunaudiodev
# To find the necessary bits, look in setup.py in detect_modules() for
# the module's name.
# --enable-shared --enable-static gave both shared and static libs.
# On Windows build is static and needs to go into contrib
  eval PYTHON_${FORPYTHON_SHARED_BUILD}_INSTALL_DIR=$CONTRIB_DIR
  if bilderConfig -I $CONTRIB_DIR Python $FORPYTHON_SHARED_BUILD "$PYTHON_PYCSH_ADDL_ARGS $PYTHON_PYCSH_OTHER_ARGS"; then
    bilderBuild Python $FORPYTHON_SHARED_BUILD
  fi

}

######################################################################
#
# Test python
#
######################################################################

testPython() {
  techo "Not testing python."
}

######################################################################
#
# Install python
#
######################################################################

installPython() {
  if bilderInstall -r Python $FORPYTHON_SHARED_BUILD python; then
    case `uname` in
      Linux)
# Fix rpath if known how
        if declare -f bilderFixRpath 1>/dev/null 2>&1; then
          bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$FORPYTHON_SHARED_BUILD/bin/python${PYTHON_MAJMIN}
          bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$FORPYTHON_SHARED_BUILD/lib/libpython${PYTHON_MAJMIN}.so
          bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$FORPYTHON_SHARED_BUILD/lib/python${PYTHON_MAJMIN}/lib-dynload
        fi
        ;;
    esac
  fi
}


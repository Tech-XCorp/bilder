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
  if $PYTHON_USE_REPO; then
    updateRepo python
    getVersion -L python
# Always install in contrib dir for consistency
    bilderPreconfig -I $CONTRIB_DIR Python
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
      PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS -DBUILD_SHARED=ON -DBUILD_STATIC=OFF -DINSTALL_WINDOWS_TRADITIONAL=ON -DPYTHON_VERSION=$PYTHON_BLDRVERSION"
      if test -z "$CMAKE_ZLIB_SERMD_LIBDIR"; then
        echo "WARNING: [$FUNCNAME] CMAKE_ZLIB_SERMD_LIBDIR not set."
      else
        zlibfile=$CMAKE_ZLIB_SERMD_LIBDIR/zlib.lib
        if test "$TARBALL_BUILD_TYPE" == "Debug"; then
          zlibfile=$CMAKE_ZLIB_SERMD_LIBDIR/zlibd.lib
        fi
        PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS -DZLIB_LIBRARY='$zlibfile' -DZLIB_INCLUDE_DIR='$CMAKE_ZLIB_SERMD_INCDIR'"
      fi
# Need a sersh build of bzip2 before this can be implemented
      if test -z "$CMAKE_BZIP2_SERSH_LIBDIR"; then
        echo "WARNING: [$FUNCNAME] CMAKE_BZIP2_SERSH_LIBDIR not set."
      else
        PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS -DBZIP2_LIBRARY='$CMAKE_BZIP2_SERSH_LIBDIR/bzip2.lib'"
      fi
# Also need BZIP2_LIBRARIES
# Remove old build directory to repatch
      rm -rf $BUILD_DIR/Python/*
      ;;
    Linux)
# If python has been built and installed from a different areas, one gets
# errors like: gcc: error: binascii.c: No such file or directory
# when compiling the modules.  It's as if the installed python has
# its own Module dir path, and when that is not found, the code fails.
# The fix seems to be to move aside the installed python and any link.
      if test -e $CONTRIB_DIR/bin/python; then
        mv $CONTRIB_DIR/bin/python $CONTRIB_DIR/bin/python.bak
      fi
      local pybindir=${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$FORPYTHON_SHARED_BUILD/bin
      if test -e $pybindir/python; then
        mv $pybindir/python $pybindir/python.bak
      fi

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

  local pydir=${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$FORPYTHON_SHARED_BUILD
  if bilderInstall -r Python $FORPYTHON_SHARED_BUILD python; then
    case `uname` in

      CYGWIN*)
        wget https://bootstrap.pypa.io/get-pip.py
        cmd="python get-pip.py"
        techo "$cmd"
        eval "$cmd"
        ;;

      Linux)
# Fix rpath if known how
        if declare -f bilderFixRpath 1>/dev/null 2>&1; then
          bilderFixRpath ${pydir}/bin/python${PYTHON_MAJMIN}
          bilderFixRpath ${pydir}/lib/libpython${PYTHON_MAJMIN}.so
          bilderFixRpath ${pydir}/lib/python${PYTHON_MAJMIN}/lib-dynload
        fi
# Remove any backups
        rm -f $CONTRIB_DIR/bin/python.bak
        rm -f $pybindir/python $pybindir/python.bak
        ;;

    esac
  else
    case `uname` in
      Linux)
# Did not install, move back old
        if test -e $CONTRIB_DIR/bin/python.bak; then
          mv $CONTRIB_DIR/bin/python.bak $CONTRIB_DIR/bin/python
        fi
        if test -e $pybindir/python.bak; then
          mv $pybindir/python $pybindir/python.bak
        fi
        ;;
    esac
  fi

}


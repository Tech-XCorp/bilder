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
  local cygwinVS12=false
  local inplace=

  # Cygwin VS12 needs in place "build" of Python, which is really just
  # an install of an already-built version.
  case `uname` in
    CYGWIN*) if test $VISUALSTUDIO_VERSION = 12; then
	       cygwinVS12=true
               inplace=-i
             fi;;
  esac

  if ! bilderUnpack $inplace Python; then
    return
  fi

  if $cygwinVS12; then
    techo "No build needed for Windows. Installing from tarball."
    if bilderConfig -C : Python sersh; then
      bilderBuild -D -k -m ./python-install.sh Python sersh
    fi
    return
  fi

# Set up flags
  if declare -f setCc4pyAddlLdflags 1>/dev/null 2>&1; then
    setCc4pyAddlLdflags
  fi
  local pyldflags="$PYCSH_ADDL_LDFLAGS"
  local pycppflags=
  case `uname` in
    Linux)
# Ensure python can find its own library and any libraries linked into contrib
      pyldflags="$pyldflags -Wl,-rpath,${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$PYTHON_BUILD/lib -L$CONTRIB_DIR/lib -Wl,-rpath,$CONTRIB_DIR/lib -Wl,--export-dynamic"
      if cd $CONTRIB_DIR/sqlite-$FORPYTHON_SHARED_BUILD; then
        local preswd=`pwd -P`
        pyldflags="$pyldflags -L$preswd/lib"
        pycppflags="-I$preswd/include"
      fi
      PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS CFLAGSFORSHARED=-fPIC"
      ;;
  esac
  if test -n "$pyldflags"; then
    PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS LDFLAGS='$pyldflags'"
  fi
  if test -n "$pycppflags"; then
    PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS CPPFLAGS='$pycppflags'"
  fi
  case $PYTHON_BLDRVERSION in
    2.6.*) ;;  # enable-unicode fails on 2.6.5
    2.7.*) PYTHON_PYCSH_ADDL_ARGS="$PYTHON_PYCSH_ADDL_ARGS --enable-unicode=ucs4";;
  esac

# just --enable-shared gives errors:
# Failed to find the necessary bits to build these modules:
#   _tkinter bsddb185 dl imageop sunaudiodev
# To find the necessary bits, look in setup.py in detect_modules() for
# the module's name.
# --enable-shared --enable-static gave both shared and static libs.
  if bilderConfig Python $FORPYTHON_SHARED_BUILD "CC='$PYC_CC $PYC_CFLAGS' --enable-shared $PYTHON_PYCSH_OTHER_ARGS $PYTHON_PYCSH_ADDL_ARGS"; then
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
  case `uname` in
    CYGWIN*) if test -n "$PYTHON_SERSH_BUILD_DIR"; then
               waitAction Python-sersh
               recordInstallation $CONTRIB_DIR Python $PYTHON_BLDRVERSION sersh
             fi
             return;;
  esac
  if bilderInstall -r Python $FORPYTHON_SHARED_BUILD python; then
    case `uname` in
      Linux)
# Fix rpath if known how
	if declare -f bilderFixRpath 1>/dev/null 2>&1; then
	  bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$PYTHON_BUILD/bin/python${PYTHON_MAJMIN}
	  bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$PYTHON_BUILD/lib/libpython${PYTHON_MAJMIN}.so
	  bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$PYTHON_BUILD/lib/python${PYTHON_MAJMIN}/lib-dynload
	fi
        ;;
    esac
  fi
}


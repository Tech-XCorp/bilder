#!/bin/bash
#
# Version and build information for python
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYTHON_BLDRVERSION_STD=2.7.3
PYTHON_BLDRVERSION_EXP=2.7.6
computeVersion Python
# Export so available to setinstald.sh
export PYTHON_BLDRVERSION

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$PYTHON_BUILDS"; then
  case `uname` in
    Linux)
      PYTHON_BUILDS=$FORPYTHON_BUILD
      PYTHON_BUILD=$FORPYTHON_BUILD
      ;;
  esac
fi
PYTHON_DEPS=chrpath,sqlite,bzip2
PYTHON_UMASK=002

addtopathvar PATH $CONTRIB_DIR/python/bin
if test `uname` = Linux; then
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/python/lib
fi
# techo "paths added."
# Recompute as if version unknown, previous calculation wrong
# Need to do after path fixed to find python.
PYTHON_MAJMIN=`echo $PYTHON_BLDRVERSION | sed 's/\([0-9]*\.[0-9]*\).*/\1/'`

######################################################################
#
# Launch python builds.
#
######################################################################

buildPython() {

  if bilderUnpack Python; then

# Set up flags
    if declare -f setCc4pyAddlLdflags 1>/dev/null 2>&1; then
      setCc4pyAddlLdflags
    fi
    local pyldflags="$CC4PY_ADDL_LDFLAGS"
    local pycppflags=
    case `uname` in
      Linux)
# Ensure python can find its own library and any libraries linked into contrib
        pyldflags="$pyldflags -Wl,-rpath,${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$PYTHON_BUILD/lib -L$CONTRIB_DIR/lib -Wl,-rpath,$CONTRIB_DIR/lib"
	if cd $CONTRIB_DIR/sqlite-sersh; then
          local preswd=`pwd -P`
          pyldflags="$pyldflags -L$preswd/lib"
          pycppflags="-I$preswd/include"
        fi
        PYTHON_CC4PY_ADDL_ARGS="$PYTHON_CC4PY_ADDL_ARGS CFLAGSFORSHARED=-fPIC"
        ;;
    esac
    if test -n "$pyldflags"; then
      PYTHON_CC4PY_ADDL_ARGS="$PYTHON_CC4PY_ADDL_ARGS LDFLAGS='$pyldflags'"
    fi
    if test -n "$pycppflags"; then
      PYTHON_CC4PY_ADDL_ARGS="$PYTHON_CC4PY_ADDL_ARGS CPPFLAGS='$pycppflags'"
    fi
    case $PYTHON_BLDRVERSION in
      2.6.*) ;;  # enable-unicode fails on 2.6.5
      2.7.*) PYTHON_CC4PY_ADDL_ARGS="$PYTHON_CC4PY_ADDL_ARGS --enable-unicode=ucs4";;
    esac

# just --enable-shared gives errors:
#  Failed to find the necessary bits to build these modules:
#  _tkinter bsddb185    dl
#  imageop  sunaudiodev
#  To find the necessary bits, look in setup.py in detect_modules() for the module's name.
# --enable-shared --enable-static gave both shared and static libs.
    if bilderConfig Python $PYTHON_BUILD "CC='$PYC_CC $PYC_CFLAGS' --enable-shared $PYTHON_CC4PY_OTHER_ARGS $PYTHON_CC4PY_ADDL_ARGS"; then
      bilderBuild Python $PYTHON_BUILD
    fi
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
  if bilderInstall -r Python $PYTHON_BUILD python; then
    case `uname` in
      Linux)
# Fix rpath if known how
	if declare -f bilderFixRpath 1>/dev/null 2>&1; then
	  bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-$PYTHON_BUILD/bin/python${PYTHON_MAJMIN}
	fi
        ;;
    esac
# If python reinstalled, then must recompute the python variables.
    source $BILDER_DIR/bilderpy.sh
  fi
}


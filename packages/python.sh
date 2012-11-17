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

PYTHON_BLDRVERSION_STD=2.6.5
PYTHON_BLDRVERSION_EXP=2.7.3
# Need to compute version and majmin here for additional load flags
if $BUILD_EXPERIMENTAL; then
  PYTHON_BLDRVERSION=${PYTHON_BLDRVERSION:-"$PYTHON_BLDRVERSION_EXP"}
else
  PYTHON_BLDRVERSION=${PYTHON_BLDRVERSION:-"$PYTHON_BLDRVERSION_STD"}
fi

######################################################################
#
# Other values
#
######################################################################

if test -z "$PYTHON_BUILDS"; then
  case `uname` in
    Linux)
      PYTHON_BUILDS=${PYTHON_BUILDS:-"cc4py"}
      ;;
  esac
fi
PYTHON_DEPS=chrpath,sqlite,bzip2

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/python/bin
# techo "Python = `which python`"
if test `uname` = Linux; then
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/python/lib
fi
# techo "paths added."
# Recompute as if version unknown, previous calculation wrong
# Need to do after path fixed to find python.
PYTHON_MAJMIN=`echo $PYTHON_BLDRVERSION | sed 's/\([0-9]*\.[0-9]*\).*/\1/'`
# Set additional load flags if known.
if declare -f setCc4pyAddlLdflags 1>/dev/null 2>&1; then
  setCc4pyAddlLdflags
fi

######################################################################
#
# Launch python builds.
#
######################################################################

buildPython() {

  if bilderUnpack Python; then

# Set up flags
    local pyldflags="$CC4PY_ADDL_LDFLAGS"
    local pycppflags=
    case `uname` in
      Linux)
# Ensure python can find its own library
        pyldflags="$pyldflags -Wl,-rpath,${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-cc4py/lib"
	if cd $CONTRIB_DIR/sqlite; then
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
    if bilderConfig Python cc4py "CC='$PYC_CC $PYC_CFLAGS' --enable-shared $PYTHON_CC4PY_OTHER_ARGS $PYTHON_CC4PY_ADDL_ARGS"; then
      bilderBuild Python cc4py
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
  if bilderInstall -r Python cc4py python; then
    case `uname` in
      Linux)
# Fix rpath if known how
	if declare -f bilderFixRpath 1>/dev/null 2>&1; then
	  bilderFixRpath ${CONTRIB_DIR}/Python-${PYTHON_BLDRVERSION}-cc4py/bin/python${PYTHON_MAJMIN}
	fi
        ;;
    esac
  fi
# Need python variables at this time regardless of whether installed
  source $BILDER_DIR/bilderpy.sh
  # techo "WARNING: Quitting at end of python.sh."; exit
}


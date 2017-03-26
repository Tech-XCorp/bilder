#!/bin/sh
######################################################################
#
# @file    pspline.sh
#
# @brief   Build information for pspline.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in pspline_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pspline_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPsplineNonTriggerVars() {
  PSPLINE_MASK=002
}
setPsplineNonTriggerVars

######################################################################
#
# Launch pspline builds.
#
######################################################################

# Build pspline using cmake
buildPsplineCM() {
# Check for svn version or package
  if test -d $PROJECT_DIR/pspline; then
    getVersion pspline
    bilderPreconfig -c pspline
    res=$?
  else
    bilderUnpack pspline
    res=$?
  fi
  if test $res = 0; then
    local PSPLINE_ENVVARS=
    case `uname`-$CC in
      CYGWIN*-mingw*)
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        PSPLINE_ENVVARS="PATH='$mingwdir:$PATH'"
        ;;
    esac
# Serial build
    if bilderConfig -c pspline ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_LINLIB_SER_ARGS $PSPLINE_SER_OTHER_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild pspline ser "" "$PSPLINE_ENVVARS"
    fi
# Parallel build
    if bilderConfig -c pspline par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_LINLIB_PAR_ARGS $PSPLINE_PAR_OTHER_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild pspline par "" "$PSPLINE_ENVVARS"
    fi
  fi
}

# For easy switching
buildPspline() {
  if test -d $PROJECT_DIR/pspline; then
    techo "WARNING: Building the repo, $PROJECT_DIR/pspline."
  fi
  if test $CONTRIB_DIR != $BLDR_INSTALL_DIR; then
    local insts=`\ls -d $BLDR_INSTALL_DIR/pspline* 2>/dev/null`
    if test -n "$insts"; then
      techo "WARNING: pspline is installed in $BLDR_INSTALL_DIR."
    fi
  fi
  # techo "For pspline, PREFER_CMAKE = $PREFER_CMAKE."
  buildPsplineCM
}

######################################################################
#
# Test pspline
#
######################################################################

testPspline() {
  techo "Not testing pspline."
}

######################################################################
#
# Install pspline
#
######################################################################

installPspline() {
  bilderInstallAll pspline
}


#!/bin/sh
######################################################################
#
# @file    scipy.sh
#
# @brief   Build information for scipy.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in scipy_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/scipy_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setScipyNonTriggerVars() {
  :
}
setScipyNonTriggerVars

#####################################################################
#
# Launch scipy builds.
#
######################################################################

setScipyBuildVars() {

# Get native fortran compiler
  local SCIPY_FC="$PYC_FC"
  if [[ `uname` =~ CYGWIN ]]; then
    SCIPY_FC=`cygpath -u "$SCIPY_FC"`
  fi

# Get build vars from numpy
  test -z "$NUMPY_ENV" && setNumpyBuildVars
  SCIPY_ENV="$NUMPY_ENV"
  SCIPY_BUILD_ARGS="$NUMPY_BUILD_ARGS"
  SCIPY_INSTALL_ARGS="$NUMPY_INSTALL_ARGS"

}

buildScipy() {

# Determine whether to unpack, whether there is a build
  if ! bilderUnpack scipy; then
    return
  fi
  local cmd=

# Move to build directory
  cd $BUILD_DIR/scipy-${SCIPY_BLDRVERSION}
# Build/install
  if $BLDR_BUILD_NUMPY && $HAVE_SER_FORTRAN; then
    setScipyBuildVars
    if [[ `uname` =~ CYGWIN ]]; then
      cmd="rmall ${PYTHON_SITEPKGSDIR}/scipy*"
      techo "$cmd"
      $cmd
    fi
    bilderDuBuild scipy "$SCIPY_BUILD_ARGS" "$SCIPY_ENV" "$SCIPY_CONFIG_ARGS"
  else
# Building at this point as only one package, and that checked by bilderUnpack
    cmd="python -m pip install --upgrade --target=$MIXED_PYTHON_SITEPKGSDIR -i https://pypi.binstar.org/carlkl/simple scipy"
    techo "$cmd"
    if $cmd; then
      ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR scipy,pycsh
      techo "scipy-pycsh installed."
      installations="$installations scipy-pycsh"
    else
      techo "scipy-pycsh failed to install."
      installFailures="$installFailures scipy-pycsh"
    fi
  fi

}

######################################################################
#
# Test scipy
#
######################################################################

testScipy() {
  techo "Not testing scipy."
}

######################################################################
#
# Install scipy
#
######################################################################

installScipy() {
  case `uname`-$PYC_CC in
    CYGWIN*) bilderDuInstall -n scipy "-" "$SCIPY_ENV";;
    *) bilderDuInstall -r scipy scipy "$SCIPY_INSTALL_ARGS" "$SCIPY_ENV";;
  esac
}


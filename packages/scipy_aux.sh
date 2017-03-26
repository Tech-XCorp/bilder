#!/bin/sh
######################################################################
#
# @file    scipy_aux.sh
#
# @brief   Trigger vars and find information for scipy.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setScipyTriggerVars() {
  if $BLDR_BUILD_NUMPY; then
    SCIPY_BLDRVERSION_STD=0.18.1
    SCIPY_BLDRVERSION_EXP=0.18.1
  else
    SCIPY_BLDRVERSION=0.16.0 # Version of available whl
  fi
  computeVersion scipy
  if $BLDR_BUILD_NUMPY && [[ `uname` =~ "CYGWIN" ]] && ! $HAVE_SER_FORTRAN; then
    SCIPY_BUILDS=${SCIPY_BUILDS:-"NONE"}
  else
    SCIPY_BUILDS=${SCIPY_BUILDS:-"pycsh"}
  fi
  SCIPY_DEPS=numpy
  if $SCIPY_USE_ATLAS; then
    SCIPY_DEPS=$SCIPY_DEPS,atlas
  fi
  SCIPY_DEPS=$SCIPY_DEPS,clapack_cmake,lapack
}
setScipyTriggerVars

######################################################################
#
# Find scipy
#
######################################################################

getInstScipyNodes() {
# Get full paths, convert to native as needed
  local nodes=("$PYTHON_SITEPKGSDIR/scipy" "$PYTHON_SITEPKGSDIR/scipy-${SCIPY_BLDRVERSION}-py${PYTHON_MAJMIN}.egg-info")
  echo ${nodes[*]}
}

findScipy() {
  techo "scipy installation nodes are `getInstScipyNodes`."
}


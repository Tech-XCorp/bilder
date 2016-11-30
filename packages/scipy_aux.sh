#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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
  SCIPY_BLDRVERSION_STD=0.13.3
  SCIPY_BLDRVERSION_EXP=0.18.1
  computeVersion scipy
  if [[ `uname` =~ "CYGWIN" ]] && ! $NUMPY_WIN_USE_FORTRAN; then
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


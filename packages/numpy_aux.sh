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

setNumpyTriggerVars() {
  NUMPY_BLDRVERSION_STD=1.8.0
  NUMPY_BLDRVERSION_EXP=1.8.1
  computeVersion numpy
  NUMPY_BUILDS=${NUMPY_BUILDS:-"cc4py"}
  NUMPY_DEPS=Python
  if $NUMPY_USE_ATLAS; then
    NUMPY_DEPS=$NUMPY_DEPS,atlas
  fi
  NUMPY_DEPS=$NUMPY_DEPS,clapack_cmake,lapack
}
setNumpyTriggerVars

######################################################################
#
# Find numpy
#
######################################################################

getInstNumpyNodes() {
# Get full paths, convert to native as needed
  local nodes=("$PYTHON_SITEPKGSDIR/numpy" "$PYTHON_SITEPKGSDIR/numpy-${NUMPY_BLDRVERSION}-py${PYTHON_MAJMIN}.egg-info")
  echo ${nodes[*]}
}

findNumpy() {
  techo "numpy installation nodes are `getInstNumpyNodes`."
}


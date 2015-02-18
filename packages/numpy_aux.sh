#!/bin/bash
#
# Trigger vars and find information

# On Windows numpy can be built with any of
#   no linear algebra libraries
#   clapack_cmake (no fortran need)
#   netlib-lapack (fortran needed)
#   atlas-clp (atlas built with clp, no fortran needed)
#   atlas-ser (atlas built with netlib-lapack, fortran needed)
# These flags determine how numpy is built, with or without fortran, atlas.

# There is also a move to using OpenBLAS
#  http://numpy-discussion.10968.n7.nabble.com/Default-builds-of-OpenBLAS-development-branch-are-now-fork-safe-td36523.html
# due to the slowness of compiling atlas.
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
  NUMPY_BLDRVERSION_STD=1.8.1
  NUMPY_BLDRVERSION_EXP=1.8.1

  if [[ `uname` =~ CYGWIN ]] && test $VISUALSTUDIO_VERSION = 12; then
    NUMPY_BLDRVERSION_STD=1.9.1
  fi

  computeVersion numpy
  NUMPY_BUILDS=${NUMPY_BUILDS:-"pycsh"}
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


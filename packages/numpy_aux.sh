#!/bin/sh
######################################################################
#
# @file    numpy_aux.sh
#
# @brief   Trigger vars and find information.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# On Windows numpy can be built with any of
#   no linear algebra libraries
#   clapack_cmake (no fortran need)
#   netlib-lapack (fortran needed)
#   openblas
# We no longer support atlas.
# These flags determine how numpy is built, with or without fortran, atlas.
#
# There is also a move to using OpenBLAS
#  http://numpy-discussion.10968.n7.nabble.com/Default-builds-of-OpenBLAS-development-branch-are-now-fork-safe-td36523.html
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
  if $BLDR_BUILD_NUMPY; then
    NUMPY_BLDRVERSION_STD=1.11.2
    NUMPY_BLDRVERSION_EXP=1.11.2
  else
    NUMPY_BLDRVERSION=1.9.2 # Version of available whl
  fi
  computeVersion numpy
  NUMPY_BUILDS=${NUMPY_BUILDS:-"pycsh"}
  NUMPY_DEPS=Python
  if $NUMPY_USE_ATLAS; then
    NUMPY_DEPS=$NUMPY_DEPS,atlas
  fi
  if [[ `uname` =~ CYGWIN ]]; then
    if $BLDR_BUILD_NUMPY; then
      if $BUILD_EXPERIMENTAL; then
        NUMPY_DEPS=$NUMPY_DEPS,openblas
      else
        NUMPY_DEPS=$NUMPY_DEPS,clapack_cmake
      fi
    fi
  else
    NUMPY_DEPS=$NUMPY_DEPS,lapack
  fi
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


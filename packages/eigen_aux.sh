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

setEigenTriggerVars() {
# Eigen 3.2.8
  EIGEN_BLDRVERSION_STD=${EIGEN_BLDRVERSION_STD:-"eigen-07105f7124f9"}
  EIGEN_BLDRVERSION_EXP=${EIGEN_BLDRVERSION_EXP:-"eigen-07105f7124f9"}
  EIGEN_BUILDS=${EIGEN_BUILDS:-"ser"}
  EIGEN_DEPS=bzip2
}
setEigenTriggerVars

######################################################################
#
# Find eigen
#
######################################################################

findEigen() {
  :
}


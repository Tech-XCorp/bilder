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

setSuperlu_DistTriggerVars() {
  SUPERLU_DIST_BLDRVERSION=${SUPERLU_DIST_BLDRVERSION:-"2.5"}
  if test -z "$SUPERLU_DIST_BUILDS"; then
    SUPERLU_DIST_BUILDS="par,parcomm"
    case `uname` in
      Linux) SUPERLU_DIST_BUILDS="${SUPERLU_DIST_BUILDS},parsh,parcommsh"
    esac
  fi
  SUPERLU_DIST_DEPS=cmake,openmpi,atlas,lapack,clapack_cmake
# Add parmetis if there are only standard builds and no commercial builds
  if !(grep -q comm <<<$SUPERLU_DIST_BUILDS); then
    SUPERLU_DIST_DEPS=$SUPERLU_DIST_DEPS,parmetis
  fi
}
setSuperlu_DistTriggerVars

######################################################################
#
# Find Superlu_Dist
#
######################################################################

findSuperlu_Dist() {
# Here we adopt the names that trilinos uses
  findContribPackage Superlu_Dist superlu_dist
}


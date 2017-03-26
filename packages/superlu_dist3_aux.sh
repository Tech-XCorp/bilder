#!/bin/sh
######################################################################
#
# @file    superlu_dist3_aux.sh
#
# @brief   Trigger vars and fine information for superlu_dist3.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
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

setSuperluDist3TriggerVars() {
# Version
  SUPERLU_DIST3_BLDRVERSION=${SUPERLU_DIST3_BLDRVERSION:-"3.3"}
# Builds
  if test -z "$SUPERLU_DIST3_DESIRED_BUILDS"; then
    SUPERLU_DIST3_DESIRED_BUILDS="par,parcomm"
    case `uname` in
      Linux) SUPERLU_DIST3_DESIRED_BUILDS="${SUPERLU_DIST3_DESIRED_BUILDS},parsh,parcommsh"
    esac
  fi
  computeBuilds superlu_dist3

# Not sure if we need the dependency to atlas, lapack and clapack_cmake
  SUPERLU_DIST3_DEPS=${SUPERLU_DIST3_DEPS:-"cmake,$MPI_BUILD,atlas,lapack,clapack_cmake"}

# Add parmetis if there are only standard builds and no commercial builds
  if !(grep -q comm <<<$SUPERLU_DIST3_BUILDS); then
    SUPERLU_DIST3_DEPS=$SUPERLU_DIST3_DEPS,parmetis
  fi
}
setSuperluDist3TriggerVars

######################################################################
#
# Find superlu_dist3
#
######################################################################

findSuperlu_Dist3() {
  :
}
findSuperlu_Dist3

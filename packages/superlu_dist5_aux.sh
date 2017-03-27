#!/bin/sh
######################################################################
#
# @file    superlu_dist5_aux.sh
#
# @brief   Trigger vars and find information for superlu_dist5.
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

setSuperlu_Dist5TriggerVars() {
  SUPERLU_DIST5_BLDRVERSION=${SUPERLU_DIST5_BLDRVERSION:-"5.1.3"}
  if test -z "$SUPERLU_DIST5_BUILDS"; then
    SUPERLU_DIST5_BUILDS="par,parcomm"
    case `uname` in
      Linux) SUPERLU_DIST5_BUILDS="${SUPERLU_DIST5_BUILDS},parsh,parcommsh"
    esac
  fi
  SUPERLU_DIST5_DEPS=cmake,$MPI_BUILD,atlas,lapack,clapack_cmake
# Add parmetis if there are only standard builds and no commercial builds
  if !(grep -q comm <<<$SUPERLU_DIST5_BUILDS); then
    SUPERLU_DIST5_DEPS=$SUPERLU_DIST5_DEPS,parmetis
  fi
}
setSuperlu_Dist5TriggerVars

######################################################################
#
# Find Superlu_Dist
#
######################################################################

findSuperlu_Dist5() {
# Here we adopt the names that trilinos uses
  findContribPackage Superlu_Dist5 superlu_dist5
}


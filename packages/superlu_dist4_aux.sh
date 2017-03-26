#!/bin/sh
######################################################################
#
# @file    superlu_dist4_aux.sh
#
# @brief   Trigger vars and find information for superlu_dist4.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
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

setSuperlu_Dist4TriggerVars() {
  SUPERLU_DIST4_BLDRVERSION=${SUPERLU_DIST4_BLDRVERSION:-"4.1"}
  if test -z "$SUPERLU_DIST4_BUILDS"; then
    SUPERLU_DIST4_BUILDS="par,parcomm"
    case `uname` in
      Linux) SUPERLU_DIST4_BUILDS="${SUPERLU_DIST4_BUILDS},parsh,parcommsh"
    esac
  fi
  SUPERLU_DIST4_DEPS=cmake,$MPI_BUILD,atlas,lapack,clapack_cmake
# Add parmetis if there are only standard builds and no commercial builds
  if !(grep -q comm <<<$SUPERLU_DIST4_BUILDS); then
    SUPERLU_DIST4_DEPS=$SUPERLU_DIST4_DEPS,parmetis
  fi
}
setSuperlu_Dist4TriggerVars

######################################################################
#
# Find Superlu_Dist
#
######################################################################

findSuperlu_Dist4() {
# Here we adopt the names that trilinos uses
  findContribPackage Superlu_Dist4 superlu_dist4
}


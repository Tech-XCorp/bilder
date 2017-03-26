#!/bin/sh
######################################################################
#
# @file    superlu_aux.sh
#
# @brief   Trigger vars and find information for superlu.
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

setSuperluTriggerVars() {
  SUPERLU_BLDRVERSION=${SUPERLU_BLDRVERSION:-"4.3"}
  if test -z "$SUPERLU_BUILDS"; then
    SUPERLU_BUILDS=ser
    case `uname` in
# JRC: sersh build needed on Darwin for pytrilinos
      Darwin | Linux) SUPERLU_BUILDS="${SUPERLU_BUILDS},sersh";;
    esac
  fi
  SUPERLU_DEPS=cmake,atlas,lapack,clapack_cmake
}
setSuperluTriggerVars

######################################################################
#
# Find oce
#
######################################################################

findSuperlu() {
  findContribPackage SuperLU superlu
}


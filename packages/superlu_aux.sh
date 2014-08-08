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

setSuperluTriggerVars() {
  SUPERLU_BLDRVERSION=${SUPERLU_BLDRVERSION:-"4.1"}
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
  :
}


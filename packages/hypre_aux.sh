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

setHypreTriggerVars() {
  HYPRE_BLDRVERSION_STD=${HYPRE_BLDRVERSION_STD:-"2.9.0b"}
  HYPRE_BLDRVERSION_EXP=${HYPRE_BLDRVERSION_EXP:-"2.9.0b"}
  if test -z "$HYPRE_BUILDS"; then
    HYPRE_BUILDS=par
    case `uname` in
      CYGWIN*) ;;
      Darwin) HYPRE_BUILDS="${HYPRE_BUILDS},parsh";;
      Linux) HYPRE_BUILDS="${HYPRE_BUILDS},parsh";;
    esac
  fi
  HYPRE_DEPS=cmake,atlas,lapack,clapack_cmake
}
setHypreTriggerVars

######################################################################
#
# Find hypre
#
######################################################################

findHypre() {
  :
}


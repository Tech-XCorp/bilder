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

setUncrustifyTriggerVars() {
  UNCRUSTIFY_BLDRVERSION_STD=${UNCRUSTIFY_BLDRVERSION:-"0.61"}
  UNCRUSTIFY_BLDRVERSION_EXP=${UNCRUSTIFY_BLDRVERSION:-"0.61"}
  case `uname` in
    CYGWIN) ;;
    *) UNCRUSTIFY_BUILDS=${UNCRUSTIFY_BUILDS:-"ser"};;
  esac
  HYPRE_DEPS=cmake,atlas,lapack,clapack_cmake
  UNCRUSTIFY_DEPS=
  UNCRUSTIFY_UMASK=002
}
setUncrustifyTriggerVars


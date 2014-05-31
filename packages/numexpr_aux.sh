#!/bin/bash
#
# Version and build information for numexpr
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

setNumexprTriggerVars() {
  NUMEXPR_BLDRVERSION_STD=${NUMEXPR_BLDRVERSION_STD:-"2.2.2"}
  NUMEXPR_BLDRVERSION_EXP=${NUMEXPR_BLDRVERSION_EXP:-"2.2.2"}
  NUMEXPR_BUILDS=${NUMEXPR_BUILDS:-"cc4py"}
  NUMEXPR_DEPS=numpy,Python
}
setNumexprTriggerVars

######################################################################
#
# Find numpy
#
######################################################################

findNumexpr() {
  :
}
findNumexpr


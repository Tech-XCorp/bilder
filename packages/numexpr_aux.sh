#!/bin/sh
######################################################################
#
# @file    numexpr_aux.sh
#
# @brief   Trigger vars and find information for numexpr.
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

setNumexprTriggerVars() {
  NUMEXPR_BLDRVERSION_STD=${NUMEXPR_BLDRVERSION_STD:-"2.6.1"}
  NUMEXPR_BLDRVERSION_EXP=${NUMEXPR_BLDRVERSION_EXP:-"2.6.1"}
  NUMEXPR_BUILDS=${NUMEXPR_BUILDS:-"pycsh"}
  NUMEXPR_DEPS=numpy,setuptools,Python
}
setNumexprTriggerVars

######################################################################
#
# Find numexpr
#
######################################################################

findNumexpr() {
  :
}
findNumexpr


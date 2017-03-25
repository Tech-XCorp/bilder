#!/bin/sh
######################################################################
#
# @file    ninja_aux.sh
#
# @brief   Trigger vars and find information for ninja.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
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

setNinjaTriggerVars() {
  NINJA_BLDRVERSION_STD=${NINJA_BLDRVERSION_STD:-"1.5.3"}
  NINJA_BLDRVERSION_EXP=${NINJA_BLDRVERSION_EXP:-"1.5.3"}
  NINJA_BUILDS=${NINJA_BUILDS:-"ser"}
  NINJA_DEPS=Python
}
setNinjaTriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

findNinja() {
  :
}


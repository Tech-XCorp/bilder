#!/bin/sh
######################################################################
#
# @file    roman_aux.sh
#
# @brief   Trigger vars and find information for roman.
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

setRomanTriggerVars() {
  ROMAN_BLDRVERSION_STD=${ROMAN_BLDRVERSION_STD:-"2.0.0"}
  ROMAN_BLDRVERSION_EXP=${ROMAN_BLDRVERSION_EXP:-"2.0.0"}
  ROMAN_BUILDS=${ROMAN_BUILDS:-"pycsh"}
  ROMAN_DEPS=Python
}
setRomanTriggerVars

######################################################################
#
# Find roman
#
######################################################################

findRoman() {
  :
}


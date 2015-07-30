#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
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


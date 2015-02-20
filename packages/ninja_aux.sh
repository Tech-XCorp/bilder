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

setNinjaTriggerVars() {
  if [[ `uname` =~ CYGWIN ]] && test $VISUALSTUDIO_VERSION = 12; then
    NINJA_BLDRVERSION_STD=${NINJA_BLDRVERSION_STD:-"1.5.3"}
  fi
  NINJA_BLDRVERSION_STD=${NINJA_BLDRVERSION_STD:-"1.4.0"}
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


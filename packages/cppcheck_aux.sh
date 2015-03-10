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

setCppcheckTriggerVars() {
  CPPCHECK_BLDRVERSION_STD=${CPPCHECK_BLDRVERSION_STD:-"1.67"}
  CPPCHECK_BLDRVERSION_EXP=${CPPCHECK_BLDRVERSION_EXP:-"1.68"}
  if ! [[ `uname` =~ CYGWIN ]]; then
    CPPCHECK_BUILDS=${CPPCHECK_BUILDS:-"ser"}
  fi
  CPPCHECK_DEPS=pcre
}
setCppcheckTriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

findCppcheck() {
  :
}


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

setShibokenTriggerVars() {
  SHIBOKEN_BLDRVERSION_STD=${SHIBOKEN_BLDRVERSION_STD:-"1.2.2"}
  SHIBOKEN_BLDRVERSION_EXP=${SHIBOKEN_BLDRVERSION_EXP:-"1.2.2"}
  SHIBOKEN_BUILDS=pycsh
  SHIBOKEN_DEPS=python
}
setShibokenTriggerVars

######################################################################
#
# Find shiboken
#
######################################################################

findShiboken() {
  :
}


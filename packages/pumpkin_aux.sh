#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
##################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setPumpkinTriggerVars() {
  PUMPKIN_BLDRVERSION=${PUMPKIN_BLDRVERSION:-"1.1.0"}
  PUMPKIN_BUILDS=${PUMPKIN_BUILDS:-"ser"}
  PUMPKIN_DEPS=glpk
}
setPumpkinTriggerVars

######################################################################
#
# Find pumpkin
#
######################################################################

findPumpkin() {
  :
}


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

setAlabasterTriggerVars() {
  ALABASTER_BLDRVERSION_STD=${ALABASTER_BLDRVERSION_STD:-"0.7.6"}
  ALABASTER_BLDRVERSION_EXP=${ALABASTER_BLDRVERSION_EXP:-"0.7.6"}
  ALABASTER_BUILDS=${ALABASTER_BUILDS:-"pycsh"}
  ALABASTER_DEPS=Python
}
setAlabasterTriggerVars

######################################################################
#
# Find alabaster
#
######################################################################

findAlabaster() {
  :
}


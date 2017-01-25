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

setCyclerTriggerVars() {
  CYCLER_BLDRVERSION_STD=${CYCLER_BLDRVERSION_STD:-"0.10.0"}
  CYCLER_BLDRVERSION_EXP=${CYCLER_BLDRVERSION_EXP:-"0.10.0"}
  CYCLER_BUILDS=${CYCLER_BUILDS:-"pycsh"}
  CYCLER_DEPS=setuptools,Python
}
setCyclerTriggerVars

######################################################################
#
# Find cycler
#
######################################################################

findCycler() {
  :
}


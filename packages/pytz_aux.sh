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

setPytzTriggerVars() {
  PYTZ_BLDRVERSION_STD=${PYTZ_BLDRVERSION_STD:-"2015.4"}
  PYTZ_BLDRVERSION_EXP=${PYTZ_BLDRVERSION_EXP:-"2015.4"}
  PYTZ_BUILDS=${PYTZ_BUILDS:-"pycsh"}
  PYTZ_DEPS=Python
}
setPytzTriggerVars

######################################################################
#
# Find pytz
#
######################################################################

findPytz() {
  :
}


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

setFutureTriggerVars() {
  FUTURE_BLDRVERSION_STD=0.16.0
  FUTURE_BLDRVERSION_EXP=0.16.0
  FUTURE_BUILDS=${EMPY_BUILDS:-"pycsh"}
  FUTURE_DEPS=setuptools,Python
}
setFutureTriggerVars

######################################################################
#
# Find uture
#
######################################################################

findFuture() {
  :
}
findFuture


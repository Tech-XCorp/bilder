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

setEMpyTriggerVars() {
  EMPY_BLDRVERSION_STD=1.1.45
  EMPY_BLDRVERSION_EXP=1.1.45
  EMPY_BUILDS=${EMPY_BUILDS:-"pycsh"}
  EMPY_DEPS=future,setuptools,Python
}
setEMpyTriggerVars

######################################################################
#
# Find EMpy
#
######################################################################

findEMpy() {
  :
}
findEMpy


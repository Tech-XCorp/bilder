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

setFuncsigsTriggerVars() {
  FUNCSIGS_BLDRVERSION_STD=${FUNCSIGS_BLDRVERSION_STD:-"0.4"}
  FUNCSIGS_BLDRVERSION_EXP=${FUNCSIGS_BLDRVERSION_EXP:-"0.4"}
  FUNCSIGS_BUILDS=${FUNCSIGS_BUILDS:-"pycsh"}
  FUNCSIGS_DEPS=setuptools,Python
}
setFuncsigsTriggerVars

######################################################################
#
# Find funcsigs
#
######################################################################

findFuncsigs() {
  :
}

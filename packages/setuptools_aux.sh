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

setSetuptoolsTriggerVars() {
  SETUPTOOLS_BLDRVERSION_STD=${SETUPTOOLS_BLDRVERSION_STD:-"2.0.2"}
  SETUPTOOLS_BLDRVERSION_EXP=${SETUPTOOLS_BLDRVERSION_EXP:-"5.2"}
  SETUPTOOLS_BUILDS=${SETUPTOOLS_BUILDS:-"pycsh"}
  SETUPTOOLS_DEPS=Python
}
setSetuptoolsTriggerVars

######################################################################
#
# Find setuptools
#
######################################################################

findSetuptools() {
  :
}


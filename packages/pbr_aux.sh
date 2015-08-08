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

setPbrTriggerVars() {
  PBR_BLDRVERSION_STD=${PBR_BLDRVERSION_STD:-"1.4.0"}
  PBR_BLDRVERSION_EXP=${PBR_BLDRVERSION_EXP:-"1.4.0"}
  PBR_BUILDS=${PBR_BUILDS:-"pycsh"}
  PBR_DEPS=setuptools,Python
}
setPbrTriggerVars

######################################################################
#
# Find pbr
#
######################################################################

findPbr() {
  :
}


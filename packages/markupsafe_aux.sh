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

setMarkupSafeTriggerVars() {
  MARKUPSAFE_BLDRVERSION_STD=${MARKUPSAFE_BLDRVERSION_STD:-"0.23"}
  MARKUPSAFE_BLDRVERSION_EXP=${MARKUPSAFE_BLDRVERSION_EXP:-"0.23"}
  MARKUPSAFE_BUILDS=${MARKUPSAFE_BUILDS:-"pycsh"}
  MARKUPSAFE_DEPS=setuptools,Python
}
setMarkupSafeTriggerVars

######################################################################
#
# Find markupsafe
#
######################################################################

findMarkupSafe() {
  :
}


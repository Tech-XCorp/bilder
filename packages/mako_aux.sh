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

setMakoTriggerVars() {
  MAKO_BLDRVERSION_STD=${MAKO_BLDRVERSION_STD:-"0.3.6"}
  MAKO_BLDRVERSION_EXP=${MAKO_BLDRVERSION_EXP:-"0.3.6"}
  MAKO_BUILDS=${MAKO_BUILDS:-"pycsh"}
  MAKO_DEPS=Python,setuptools
}
setMakoTriggerVars

######################################################################
#
# Find mako
#
######################################################################

findMako() {
  :
}


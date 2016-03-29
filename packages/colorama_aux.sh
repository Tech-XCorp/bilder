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

setColoramaTriggerVars() {
  COLORAMA_BLDRVERSION_STD=${COLORAMA_BLDRVERSION_STD:-"0.3.3"}
  COLORAMA_BLDRVERSION_EXP=${COLORAMA_BLDRVERSION_EXP:-"0.3.6"}
  COLORAMA_BUILDS=${COLORAMA_BUILDS:-"pycsh"}
  COLORAMA_DEPS=Python
}
setColoramaTriggerVars

######################################################################
#
# Find colorama
#
######################################################################

findColorama() {
  :
}


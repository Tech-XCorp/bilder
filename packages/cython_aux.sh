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

setCythonTriggerVars() {
  CYTHON_BLDRVERSION_STD=0.19.2
  CYTHON_BLDRVERSION_EXP=0.20.1
  CYTHON_BUILDS=${CYTHON_BUILDS:-"pycsh"}
  CYTHON_DEPS=Python
  if $HAVE_ATLAS_PYC; then
    CYTHON_DEPS="$CYTHON_DEPS,atlas"
  fi
}
setCythonTriggerVars

######################################################################
#
# Find cython
#
######################################################################

findCython() {
  :
}
findCython


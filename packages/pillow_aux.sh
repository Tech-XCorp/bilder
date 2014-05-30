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

setPillowTriggerVars() {
  PILLOW_BLDRVERSION=${PILLOW_BLDRVERSION:-"2.4.0"}
  PILLOW_BUILDS=${PILLOW_BUILDS:-"cc4py"}
  PILLOW_DEPS=Python
}
setPillowTriggerVars

######################################################################
#
# Find imaging
#
######################################################################

findPillow() {
  :
}


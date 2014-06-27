#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
##################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setTxphysicsTriggerVars() {
# txphysics used only by engine, so no sersh build needed
  TXPHYSICS_BUILDS=${TXPHYSICS_BUILDS:-"ser"}
  computeBuilds txphysics
  addBenBuild txphysics
  TXPHYSICS_DEPS=cmake
}
setTxphysicsTriggerVars

######################################################################
#
# Find txphysics
#
######################################################################

findTxphysics() {
  :
}


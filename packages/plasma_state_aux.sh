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

setPlasma_stateTriggerVars() {
  PLASMA_STATE_BLDRVERSION=${PLASMA_STATE_BLDRVERSION:-"2.7.0-r214"}
  PLASMA_STATE_TAR_BLDRVERSION=${PLASMA_STATE_TAR_BLDRVERSION:-"1.0.2"}
  PLASMA_STATE_BUILDS=${PLASMA_STATE_BUILDS:-"ser"}
  addBenBuild plasma_state
  PLASMA_STATE_DEPS=pspline,netlib_lite,netcdf,hdf5
}
setPlasma_stateTriggerVars

######################################################################
#
# Find plasma_state
#
######################################################################

findPlasma_state() {
  :
}


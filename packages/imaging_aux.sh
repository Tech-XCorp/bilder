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

setImagingTriggerVars() {
  IMAGING_BLDRVERSION=${IMAGING_BLDRVERSION:-"1.1.7"}
  IMAGING_BUILDS=${IMAGING_BUILDS:-"cc4py"}
  IMAGING_DEPS=Python
}
setImagingTriggerVars

######################################################################
#
# Find imaging
#
######################################################################

findImaging() {
  :
}


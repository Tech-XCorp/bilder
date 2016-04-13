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

setNdiffTriggerVars() {
  NDIFF_BLDRVERSION_STD=2.00
  NDIFF_BLDRVERSION_EXP=2.00
  NDIFF_BUILDS=ser
  NDIFF_DEPS=automake
}
setNdiffTriggerVars

######################################################################
#
# Find ndiff
#
######################################################################

findNdiff() {
    addtopathvar PATH $CONTRIB_DIR/ndiff/bin
    getCombinedCompVars
}


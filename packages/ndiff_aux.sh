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
  NDIFF_BLDRVERSION_STD=2.0.0
  NDIFF_BLDRVERSION_EXP=2.0.0
  if $BUILD_MPIS && test -z "$NDIFF_BUILDS" && [[ $USE_MPI =~ ndiff ]]; then
    NDIFF_BUILDS=ser
  fi
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


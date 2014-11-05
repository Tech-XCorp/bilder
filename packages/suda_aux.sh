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

setTxradTriggerVars() {
  SUDA_BUILD="$FORPYTHON_SHARED_BUILD"
  SUDA_DESIRED_BUILDS=${SUDA_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  computeBuilds suda
  SUDA_DEPS=gras
}
setTxradTriggerVars

######################################################################
#
# Find txutils
#
######################################################################

findTxrad() {
  :
}


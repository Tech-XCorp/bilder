#!/bin/bash
#
# Build information for hwloc
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in hwloc_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/hwloc_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setHypreNonTriggerVars() {
  HWLOC_UMASK=002
}
setHypreNonTriggerVars

######################################################################
#
# Other values
#
######################################################################

HWLOC_DEPS=autotools

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch hwloc builds.
#
######################################################################

buildHwloc() {
  if ! bilderUnpack hwloc; then
    return
  fi
  if bilderConfig hwloc ser; then
    bilderBuild hwloc ser
  fi
}

######################################################################
#
# Test hwloc
#
######################################################################

testHwloc() {
  techo "Not testing hwloc."
}

######################################################################
#
# Install hwloc
#
######################################################################

installHwloc() {
  bilderInstall hwloc ser
}


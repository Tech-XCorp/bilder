#!/bin/bash
#
# Build information for pyne
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pyne_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pyne_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPyneNonTriggerVars() {
  :
}
setPyneNonTriggerVars

######################################################################
#
# Launch pyne builds.
#
######################################################################

buildPyne() {

  if ! bilderUnpack pyne; then
    return
  fi

# Build/install
  bilderDuBuild pyne "$PYNE_ARGS" "$PYNE_ENV"

}

######################################################################
#
# Test pyne
#
######################################################################

testPyne() {
  techo "Not testing pyne."
}

######################################################################
#
# Install pyne
#
######################################################################

installPyne() {

# Install library if not present, make link if needed
  if bilderDuInstall $instopts pyne "$PYNE_ARGS" "$PYNE_ENV"; then
    :
  fi

}


#!/bin/bash
#
# Build information for requests
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in requests_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/requests_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setRequestsNonTriggerVars() {
  REQUESTS_UMASK=002
}
setRequestsNonTriggerVars

#####################################################################
#
# Launch requests builds.
#
######################################################################

buildRequests() {
  if ! bilderUnpack requests; then
    return
  fi
  REQUESTS_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/requests.files'"
  bilderDuBuild requests
}

######################################################################
#
# Test requests
#
######################################################################

testRequests() {
  techo "Not testing requests."
}

######################################################################
#
# Install requests
#
######################################################################

installRequests() {
  bilderDuInstall requests "$REQUESTS_INSTALL_ARGS"
}


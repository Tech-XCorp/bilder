#!/bin/bash
#
# Build information for exprtk
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in exprtk_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/exprtk_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setExprtkNonTriggerVars() {
  EXPRTK_UMASK=002
}
setExprtkNonTriggerVars

######################################################################
#
# Launch builds
#
######################################################################

buildExprtk() {
# Configure and build
  if ! bilderUnpack exprtk; then
    return
  fi
  if bilderConfig exprtk ser "" ""; then
    bilderBuild exprtk ser
  fi
}

######################################################################
#
# Test
#
######################################################################

testExprtk() {
  techo "Not testing exprtk."
}

######################################################################
#
# Install
#
######################################################################

installExprtk() {
  bilderInstall exprtk ser
}


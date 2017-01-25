#!/bin/bash
#
# Build information for typing
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in typing_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/typing_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTypingNonTriggerVars() {
  TYPING_UMASK=002
}
setTypingNonTriggerVars

#####################################################################
#
# Launch typing builds.
#
######################################################################

buildTyping() {
  if bilderUnpack typing; then
    bilderDuBuild typing
  fi
}

######################################################################
#
# Test typing
#
######################################################################

testTyping() {
  techo "Not testing typing."
}

######################################################################
#
# Install typing
#
######################################################################

installTyping() {
  bilderDuInstall typing
}


#!/bin/sh
######################################################################
#
# @file    typing.sh
#
# @brief   Build information for typing.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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


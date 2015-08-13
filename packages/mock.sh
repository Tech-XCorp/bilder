#!/bin/bash
#
# Build information for mock
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in mock_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/mock_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMockNonTriggerVars() {
  MOCK_UMASK=002
}
setMockNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildMock() {
  if bilderUnpack mock; then
    bilderDuBuild mock "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testMock() {
  techo "Not testing Mock."
}

######################################################################
#
# Install
#
######################################################################

installMock() {
  local MOCK_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/mock.filelist'"
  bilderDuInstall mock "$MOCK_INSTALL_ARGS" "$DISTUTILS_ENV"
}

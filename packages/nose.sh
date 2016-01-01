#!/bin/bash
#
# Build information for nose
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in nose_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/nose_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNoseNonTriggerVars() {
  NOSE_UMASK=002
}
setNoseNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildNose() {
  if ! bilderUnpack nose; then
    return
  fi
# Remove eggs as Bilder manages
  cmd="rm -rf ${PYTHON_SITEPKGSDIR}/nose*.egg"
  techo -2 "$cmd"
  $cmd
# Build
  bilderDuBuild nose "" "$DISTUTILS_ENV"
}

######################################################################
#
# Test
#
######################################################################

testNose() {
  techo "Not testing Nose."
}

######################################################################
#
# Install
#
######################################################################

installNose() {
  local NOSE_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/nose.filelist'"
  bilderDuInstall nose "$NOSE_INSTALL_ARGS" "$DISTUTILS_ENV"
}


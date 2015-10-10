#!/bin/bash
#
# Build information for pbr
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pbr_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pbr_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPbrNonTriggerVars() {
  PBR_UMASK=002
}
setPbrNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildPbr() {
  if bilderUnpack pbr; then
    bilderDuBuild pbr "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testPbr() {
  techo "Not testing Pbr."
}

######################################################################
#
# Install
#
######################################################################

installPbr() {
  local PBR_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/pbr.filelist'"
  bilderDuInstall pbr "$PBR_INSTALL_ARGS" "$DISTUTILS_ENV"
}


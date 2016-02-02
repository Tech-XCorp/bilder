#!/bin/bash
#
# Build information for funcsigs
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in funcsigs_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/funcsigs_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setFuncsigsNonTriggerVars() {
  FUNCSIGS_UMASK=002
}
setFuncsigsNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildFuncsigs() {
  if bilderUnpack funcsigs; then
    bilderDuBuild funcsigs "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testFuncsigs() {
  techo "Not testing Funcsigs."
}

######################################################################
#
# Install
#
######################################################################

installFuncsigs() {
  local FUNCSIGS_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/funcsigs.files'"
  bilderDuInstall funcsigs "$FUNCSIGS_INSTALL_ARGS" "$DISTUTILS_ENV"
}


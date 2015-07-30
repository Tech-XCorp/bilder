#!/bin/bash
#
# Build information for pygments
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pygments_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pygments_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setDocutilsNonTriggerVars() {
  PYGMENTS_UMASK=002
}
setDocutilsNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildPygments() {
  if bilderUnpack Pygments; then
    bilderDuBuild -p pygments Pygments "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testPygments() {
  techo "Not testing Pygments."
}

######################################################################
#
# Install
#
######################################################################

installPygments() {
  local PYGMENTS_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/pygments.filelist'"
  bilderDuInstall -r Pygments -p pygments Pygments "$PYGMENTS_INSTALL_ARGS" "$DISTUTILS_ENV"
}


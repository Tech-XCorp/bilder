#!/bin/bash
#
# Build information for cycler
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in cycler_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/cycler_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCyclerNonTriggerVars() {
  CYCLER_UMASK=002
}
setCyclerNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildCycler() {
  if ! bilderUnpack cycler; then
    return
  fi
  CYCLER_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/cycler.files'"
  # bilderDuBuild cycler "" "$DISTUTILS_ENV"
  bilderDuBuild cycler
}

######################################################################
#
# Test
#
######################################################################

testCycler() {
  techo "Not testing Cycler."
}

######################################################################
#
# Install
#
######################################################################

installCycler() {
  # bilderDuInstall cycler "$CYCLER_INSTALL_ARGS" "$DISTUTILS_ENV"
  bilderDuInstall cycler "$CYCLER_INSTALL_ARGS"
}


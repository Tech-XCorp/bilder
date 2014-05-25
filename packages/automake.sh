#!/bin/bash
#
# Build information for automake
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in automake_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/automake_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setAutomakeNonTriggerVars() {
  AUTOMAKE_UMASK=002
}
setAutomakeNonTriggerVars

######################################################################
#
# Launch automake builds.
#
######################################################################

buildAutomake() {
# If executable not found, under prefix, needs installing
  if ! test -x $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/automake; then
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR automake,ser
  fi
# Build
  if ! bilderUnpack automake; then
    return
  fi
  if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION automake ser; then
    bilderBuild -m make automake ser
  fi
}

######################################################################
#
# Test automake
#
######################################################################

testAutomake() {
  techo "Not testing automake."
}

######################################################################
#
# Install automake
#
######################################################################

installAutomake() {
  bilderInstall -m make automake ser autotools
}


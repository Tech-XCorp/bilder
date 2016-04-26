#!/bin/bash
#
# Build information for shiboken
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in shiboken_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/shiboken_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setShibokenNonTriggerVars() {
  SHIBOKEN_UMASK=002
}
setShibokenNonTriggerVars

######################################################################
#
# Launch shiboken builds.
#
######################################################################

buildShiboken() {

# Get version, see about installing
  if ! bilderUnpack shiboken; then
    return
  fi

# configure and install
  if bilderConfig shiboken ser; then
    bilderBuild shiboken ser
  fi

}

######################################################################
#
# Test shiboken
#
######################################################################

testShiboken() {
  techo "Not testing shiboken."
}

######################################################################
#
# Install shiboken
#
######################################################################

installShiboken() {
  if bilderInstall shiboken ser; then
    ln -sf $CONTRIB_DIR/shiboken/bin/shiboken $CONTRIB_DIR/bin/shiboken
  fi
}


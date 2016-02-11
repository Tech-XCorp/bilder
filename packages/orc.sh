#!/bin/bash
#
# Build information for orc
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in orc_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/orc_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOrcNonTriggerVars() {
  ORC_UMASK=002
}
setOrcNonTriggerVars

######################################################################
#
# Launch orc builds.
#
######################################################################

buildOrc() {
# Unpack
  if ! bilderUnpack orc; then
    return
  fi
# Build
  if bilderConfig orc sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $ORC_SER_OTHER_ARGS"; then
    bilderBuild orc sersh
  fi
}

######################################################################
#
# Test orc
#
######################################################################

testOrc() {
  techo "Not testing orc."
}

######################################################################
#
# Install orc
#
######################################################################

installOrc() {
  bilderInstall orc sersh
}


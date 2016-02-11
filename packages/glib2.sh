#!/bin/bash
#
# Build information for glib2
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in glib2_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/glib2_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setGlib2NonTriggerVars() {
  GLIB2_UMASK=002
}
setGlib2NonTriggerVars

######################################################################
#
# Launch glib2 builds.
#
######################################################################

buildGlib2() {
# Unpack
  if ! bilderUnpack glib2; then
    return
  fi
# Build
  if bilderConfig glib2 sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $GLIB2_SER_OTHER_ARGS"; then
    bilderBuild glib2 sersh
  fi
  if bilderConfig glib2 pycsh "--enable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $GLIB2_SER_OTHER_ARGS"; then
    bilderBuild glib2 pycsh
  fi
}

######################################################################
#
# Test glib2
#
######################################################################

testGlib2() {
  techo "Not testing glib2."
}

######################################################################
#
# Install glib2
#
######################################################################

installGlib2() {
  bilderInstall glib2 sersh
}


#!/bin/bash
#
# Build information for gstreamer
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in gstreamer_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/gstreamer_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setGstreamerNonTriggerVars() {
  GSTREAMER_UMASK=002
}
setGstreamerNonTriggerVars

######################################################################
#
# Launch gstreamer builds.
#
######################################################################

buildGstreamer() {
# Unpack
  if ! bilderUnpack gstreamer; then
    return
  fi
# Build
  if bilderConfig gstreamer sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $GSTREAMER_SER_OTHER_ARGS"; then
    bilderBuild gstreamer sersh
  fi
  if bilderConfig gstreamer pycsh "--enable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $GSTREAMER_SER_OTHER_ARGS"; then
    bilderBuild gstreamer pycsh
  fi
}

######################################################################
#
# Test gstreamer
#
######################################################################

testGstreamer() {
  techo "Not testing gstreamer."
}

######################################################################
#
# Install gstreamer
#
######################################################################

installGstreamer() {
  bilderInstall gstreamer sersh
}


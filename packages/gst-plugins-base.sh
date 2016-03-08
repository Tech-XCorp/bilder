#!/bin/bash
#
# Build information for gstpluginsbase
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in gstpluginsbase_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/gst-plugins-base_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setGst_plugins_baseNonTriggerVars() {
  GST_PLUGINS_BASE_UMASK=002
}
setGst_plugins_baseNonTriggerVars

######################################################################
#
# Launch gst-plugins-base builds.
#
######################################################################

buildGst_plugins_base() {
# Unpack
  if ! bilderUnpack gst-plugins-base; then
    return
  fi
# Build
  if bilderConfig -p gstreamer-${GSTREAMER_BLDRVERSION}-sersh  gst-plugins-base sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $GST_PLUGINS_BASE_SER_OTHER_ARGS"; then
    bilderBuild gst-plugins-base sersh
  fi
}

######################################################################
#
# Test gstpluginsbase
#
######################################################################

testGst_plugins_base() {
  techo "Not testing gst-plugins-base."
}

######################################################################
#
# Install gstpluginsbase
#
######################################################################

installGst_plugins_base() {
  bilderInstall gst-plugins-base sersh
}


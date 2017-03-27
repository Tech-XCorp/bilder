#!/bin/sh
######################################################################
#
# @file    gst_plugins_base.sh
#
# @brief   Build information for gst_plugins_base.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in gstpluginsbase_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/gst_plugins_base_aux.sh

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
  if ! bilderUnpack gst_plugins_base; then
    return
  fi
# Build
  if bilderConfig -p gstreamer-${GSTREAMER_BLDRVERSION}-sersh  gst_plugins_base sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $GST_PLUGINS_BASE_SER_OTHER_ARGS"; then
    bilderBuild gst_plugins_base sersh
  fi
  if bilderConfig -p gstreamer-${GSTREAMER_BLDRVERSION}-ser  gst_plugins_base ser " $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $GST_PLUGINS_BASE_SER_OTHER_ARGS"; then
    bilderBuild gst_plugins_base ser
  fi
  if bilderConfig -p gstreamer-${GSTREAMER_BLDRVERSION}-pycsh  gst_plugins_base pycsh "--enable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $GST_PLUGINS_BASE_SER_OTHER_ARGS"; then
    bilderBuild gst_plugins_base pycsh
  fi
  if bilderConfig -p gstreamer-${GSTREAMER_BLDRVERSION}-pycst  gst_plugins_base pycst "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $GST_PLUGINS_BASE_SER_OTHER_ARGS"; then
    bilderBuild gst_plugins_base pycst
  fi
}

######################################################################
#
# Test gstpluginsbase
#
######################################################################

testGst_plugins_base() {
  techo "Not testing gst_plugins_base."
}

######################################################################
#
# Install gstpluginsbase
#
######################################################################

installGst_plugins_base() {
  if [[ $GST_PLUGINS_BASE_BUILDS =~ sersh ]]; then
    bilderInstall gst_plugins_base sersh
  fi
  if [[ $GST_PLUGINS_BASE_BUILDS =~ ser ]]; then
    bilderInstall gst_plugins_base ser
  fi
  if [[ $GST_PLUGINS_BASE_BUILDS =~ pycsh ]]; then
    bilderInstall gst_plugins_base pycsh
  fi
  if [[ $GST_PLUGINS_BASE_BUILDS =~ pycst ]]; then
    bilderInstall gst_plugins_base pycst
  fi
}


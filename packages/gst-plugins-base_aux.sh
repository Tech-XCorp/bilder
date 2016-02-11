#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setGst_plugins_baseTriggerVars() {
  GST_PLUGINS_BASE_BLDRVERSION_STD=${GST_PLUGINS_BASE_BLDRVERSION_STD:-"0.10.36"}
  GST_PLUGINS_BASE_BLDRVERSION_EXP=${GST_PLUGINS_BASE_BLDRVERSION_EXP:-"0.10.36"}
  if test `uname` = Linux; then
    GST_PLUGINS_BASE_BUILDS=${GST_PLUGINS_BASE_BUILDS:-"$FORPYTHON_BUILD"}
    if test -n `which gstreamer-0.10`; then
      techo "Gstreamer already in path, "
      techo "should be OK for phonon to build with this package"
      techo "If it does not please check gstreamer-devel package"
      techo "is installed"
    else
      QT_DEPS=${QT_DEPS},gst-plugins-base
    fi
  fi
  fi
  GST_PLUGINS_BASE_DEPS=gstreamer
  # GSTREAMER_TARBALLBASE=gst-plugins-base
}
setGst_plugins_baseTriggerVars

######################################################################
#
# Find gstpluginsbase
#
######################################################################

findGst_plugins_base() {
  : # findContribPackage Gst_plugins_base gstpluginsbase-1.0 sersh pycsh
  # findPycshDir Gstpluginsbase
  # addToPathVar PKG_CONFIG_PATH $CONTRIB_DIR/gstpluginsbase-${GST_PLUGINS_BASE_BLDRVERSION}-sersh/lib/pkgconfig
}


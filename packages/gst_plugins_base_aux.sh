#!/bin/sh
######################################################################
#
# @file    gst_plugins_base_aux.sh
#
# @brief   Trigger vars and find information for gst_plugins_base.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
    GST_PLUGINS_BASE_BUILDS=${GST_PLUGINS_BASE_BUILDS:-"${FORPYTHON_SERIAL_BUILD},sersh"}
    GST_PLUGINS_BASE_BUILD="pycsh"
# JRC: not understanding.  gstreamer-0.10 is not an executable on my machine,
# but my build proceeds just fine without this build.
    if which gstreamer-0.10; then
      techo "Gstreamer already in path, "
      techo "should be OK for phonon to build with this package"
      techo "If it does not please check gstreamer-devel package"
      techo "is installed"
    else
      techo "Gstreamer was not found, adding to dependencies"
      GST_PLUGINS_BASE_DEPS=${GST_PLUGINS_BASE_DEPS},gstreamer
    fi
  fi
}
setGst_plugins_baseTriggerVars

######################################################################
#
# Find gstpluginsbase
#
######################################################################

findGst_plugins_base() {
  findContribPackage Gst_plugins_base gst-plugins-base-1.0 sersh pycsh
  findPycshDir Gst_plugins_base
  addToPathVar PKG_CONFIG_PATH $CONTRIB_DIR/gst_plugins_base-${GST_PLUGINS_BASE_BLDRVERSION}-sersh/lib/pkgconfig
}


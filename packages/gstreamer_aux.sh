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

setGstreamerTriggerVars() {
  GSTREAMER_BLDRVERSION_STD=${GSTREAMER_BLDRVERSION_STD:-"1.7.1"}
  GSTREAMER_BLDRVERSION_EXP=${GSTREAMER_BLDRVERSION_EXP:-"1.7.1"}
  if test `uname` = Linux; then
    GSTREAMER_BUILDS=${GSTREAMER_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  fi
  GSTREAMER_DEPS=libtool,xz
}
setGstreamerTriggerVars

######################################################################
#
# Find gstreamer
#
######################################################################

findGstreamer() {
  findContribPackage Gstreamer gstreamer-1.0 sersh pycsh
  findPycshDir Gstreamer
  addToPathVar PKG_CONFIG_PATH $CONTRIB_DIR/gstreamer-${GSTREAMER_BLDRVERSION}-sersh/lib/pkgconfig
}


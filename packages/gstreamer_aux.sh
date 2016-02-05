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
  GSTREAMER_BLDRVERSION_STD=${GSTREAMER_BLDRVERSION_STD:-"0.10.36"}
  GSTREAMER_BLDRVERSION_EXP=${GSTREAMER_BLDRVERSION_EXP:-"0.10.36"}
  if test `uname` = Linux; then
    GSTREAMER_BUILDS=${GSTREAMER_BUILDS:-"sersh"}
    addPycshBuild gstreamer
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
  findContribPackage Gstreamer gstreamer sersh pycsh
  findPycshDir Gstreamer
}


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

getTulipTriggerVars() {
  TULIP_BLDRVERSION=${TULIP_BLDRVERSION:-"4.6.0"}
  TULIP_BUILDS=${TULIP_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  TULIP_DEPS=qt,cmake
}
getTulipTriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

findTulip() {
  addtopathvar PATH $CONTRIB_DIR/tulip/bin
}


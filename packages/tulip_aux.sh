#!/bin/sh
######################################################################
#
# @file    tulip_aux.sh
#
# @brief   Trigger vars and find information for tulip.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
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


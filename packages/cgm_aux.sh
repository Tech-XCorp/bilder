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

setCgmTriggerVars() {
  CGM_BUILD=$FORPYTHON_BUILD
  CGM_BUILDS=${CGM_BUILDS:-"$FORPYTHON_BUILD"}
  CGM_DEPS=oce,cmake
}
setCgmTriggerVars

######################################################################
#
# Find cgm
#
######################################################################

# Find the directory containing the OCE cmake files
findCgm() {
  findPackage Cgm cubit_facet "$BLDR_INSTALL_DIR" cc4py sersh
  findCc4pyDir Cgm
}


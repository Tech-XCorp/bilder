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
  CGM_REPO_URL=https://bitbucket.org/cadg4/cgm.git
  CGM_UPSTREAM_URL=https://bitbucket.org/fathomteam/cgm.git
  CGM_REPO_TAG_EXP=master
  CGM_BUILD=$FORPYTHON_SHARED_BUILD
  CGM_BUILDS=${CGM_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
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
  findPackage Cgm cubit_facet "$BLDR_INSTALL_DIR" pycsh sersh
  findPycshDir Cgm
}


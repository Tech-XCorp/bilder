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

setMoabTriggerVars() {
  MOAB_REPO_URL=https://bitbucket.org/cadg4/moab.git
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_REPO_BRANCH_STD=master
  MOAB_REPO_BRANCH_EXP=master
  MOAB_BUILD=$FORPYTHON_BUILD
  MOAB_BUILDS=${MOAB_BUILDS:-"ser,par,$FORPYTHON_BUILD"}
  MOAB_DEPS=cgm,netcdf
}
setMoabTriggerVars

######################################################################
#
# Find moab
#
######################################################################

findMoab() {
  findPackage Moab MOAB "$BLDR_INSTALL_DIR" sersh cc4py
  findCc4pyDir Moab
}


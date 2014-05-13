#!/bin/bash
#
# Version information for moab
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

setMoabVersion() {
  MOAB_REPO_URL=https://bitbucket.org/cadg4/moab.git
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_REPO_BRANCH_STD=master
  MOAB_REPO_BRANCH_EXP=master
}
setMoabVersion

######################################################################
#
# Find moab
#
######################################################################

findMoab() {
  findPackage Moab MOAB "$BLDR_INSTALL_DIR" sersh cc4py
  findCc4pyDir Moab
}


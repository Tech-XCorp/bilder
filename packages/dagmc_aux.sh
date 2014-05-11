#!/bin/bash
#
# Version and find information for dagmc
#
# $Id$
#
######################################################################

getDagMcVersion() {
  DAGMC_REPO_URL=https://github.com/makeclean/DAGMC.git
  DAGMC_UPSTREAM_URL=https://github.com/makeclean/DAGMC.git
  DAGMC_REPO_BRANCH_STD=develop
  DAGMC_REPO_BRANCH_EXP=develop
}
getDagMcVersion

######################################################################
#
# Find dagmc
#
######################################################################

# Compute vars that help to find dagmc
findDagMc() {

# Look for DagMc in the contrib directory
  findPackage DagMc TKMath "$BLDR_INSTALL_DIR" cc4py sersh
  findCc4pyDir DagMc

}


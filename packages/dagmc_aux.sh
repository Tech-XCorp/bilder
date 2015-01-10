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

setDagMcTriggerVars() {
  DAGMC_REPO_URL=https://github.com/Tech-XCorp/DAGMC.git
  DAGMC_REPO_BRANCH_STD=${DAGMC_REPO_BRANCH_STD:-"develop"}
  DAGMC_REPO_BRANCH_EXP=${DAGMC_REPO_BRANCH_EXP:-"develop"}
  DAGMC_UPSTREAM_URL=https://github.com/svalinn/DAGMC.git
  DAGMC_UPSTREAM_BRANCH=develop
  DAGMC_BUILDS=${DAGMC_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  DAGMC_DEPS=geant4,moab,boost,pyne,pytaps
}
setDagMcTriggerVars

######################################################################
#
# Find dagmc
#
######################################################################

# Compute vars that help to find dagmc
findDagMc() {
# Look for DagMc in the contrib directory
  findPackage DagMc dagsolid "$BLDR_INSTALL_DIR" pycsh sersh
  findPycshDir DagMc
}


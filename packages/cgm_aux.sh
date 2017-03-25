#!/bin/sh
######################################################################
#
# @file    cgm_aux.sh
#
# @brief   Trigger vars and find information for cgm.
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

setCgmTriggerVars() {
  CGM_REPO_URL=https://bitbucket.org/cadg4/cgm.git
  CGM_REPO_BRANCH_STD=stable
  CGM_REPO_BRANCH_EXP=master
  CGM_UPSTREAM_URL=https://bitbucket.org/fathomteam/cgm.git
  CGM_UPSTREAM_BRANCH=master
  if test -z "$CGM_DESIRED_BUILDS"; then
# Static serial and parallel builds needed for ulixes,
    CGM_DESIRED_BUILDS=ser
# Python shared build needed for composers
# Python shared build needed for dagmc
# Neither pycst nor pycsh working on Windows
    if ! [[ `uname` =~ CYGWIN ]]; then
      CGM_DESIRED_BUILDS=${CGM_DESIRED_BUILDS},${FORPYTHON_SHARED_BUILD}
    fi
  fi
  computeBuilds cgm
  CGM_DEPS=$USE_OCC,autotools,cmake
}
setCgmTriggerVars

######################################################################
#
# Find cgm
#
######################################################################

# Find the directory containing the OCE cmake files
findCgm() {
# The library is cgma in stable, cgm in master, but iGeom is in both
  findPackage Cgm iGeom "$BLDR_INSTALL_DIR" pycsh sersh
  findPycshDir Cgm
}


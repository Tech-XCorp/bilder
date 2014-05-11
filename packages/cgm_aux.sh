#!/bin/bash
#
# Version information for cgm
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

setCgmVersion() {
  CGM_REPO_URL=https://bitbucket.org/cadg4/cgm.git
  CGM_UPSTREAM_URL=https://bitbucket.org/fathomteam/cgm.git
  CGM_REPO_TAG_STD=master
  CGM_REPO_TAG_EXP=master
}
setCgmVersion

######################################################################
#
# Find cgm
#
######################################################################

# Find the directory containing the OCE cmake files
findCgm() {

# Look for cgm in the contrib directory
  findPackage Cgm cubit_facet "$BLDR_INSTALL_DIR" cc4py sersh
  findCc4pyDir Cgm

}

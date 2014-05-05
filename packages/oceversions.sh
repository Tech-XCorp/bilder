#!/bin/bash
#
# Version and build information for oce
#
# $Id$
#
######################################################################

getOceVersion() {
  # OCE_BLDRVERSION=${OCE_BLDRVERSION:-"0.10.1-r747"}
  OCE_REPO_URL=git://github.com/tpaviot/oce.git
  OCE_UPSTREAM_URL=git://github.com/tpaviot/oce.git
  OCE_REPO_TAG_STD=OCE-0.14.1
  OCE_REPO_TAG_EXP=master
}
getOceVersion


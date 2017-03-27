#!/bin/sh
######################################################################
#
# @file    sowing.sh
#
# @brief   Version and build information for sowing.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

SOWING_BLDRVERSION=${SOWING_BLDRVERSION:-"1.1.20"}
SOWING_BUILDS=${SOWING_BUILDS:-"ser"}
SOWING_DEPS=

######################################################################
#
# Launch sowing builds.
#
######################################################################

buildSowing() {
  if ! bilderUnpack -i sowing; then
    return
  fi
  for bld in ${SOWING_BUILDS}; do
    if bilderConfig -i sowing $bld; then
      bilderBuild sowing $bld
    fi
  done
}

######################################################################
#
# Test sowing
#
######################################################################

testSowing() {
  techo "Not testing sowing"
}

######################################################################
#
# Install sowing
#
######################################################################

installSowing() {
  for bld in ${SOWING_BUILDS}; do
    bilderInstall sowing ser
  done
}
######################################################################
#
# Find sowing
#
######################################################################

findSowing() {
  addtopathvar PATH $CONTRIB_DIR/sowing/bin
}


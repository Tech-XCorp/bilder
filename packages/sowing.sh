#!/bin/bash
#
# Build information for sowing
#
# $Id$
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


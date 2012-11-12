#!/bin/bash
#
# Version and build information for gtest
#
# $Id: gtest.sh 4213 2011-08-31 21:26:26Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GTEST_BLDRVERSION=${GTEST_BLDRVERSION:-"1.5.0"}

######################################################################
#
# Other values
#
######################################################################

GTEST_BUILDS=${GTEST_BUILDS:-"ser"}
GTEST_DEPS=

######################################################################
#
# Launch gtest builds.
#
######################################################################

buildGtest() {

# Simplest case
  if bilderUnpack gtest; then
    if bilderConfig -c gtest ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $GTEST_SER_OTHER_ARGS"; then
      bilderBuild gtest ser
    fi
  fi

}

######################################################################
#
# Test gtest
#
######################################################################

testGtest() {
  techo "Not testing gtest."
}

######################################################################
#
# Install gtest
#
######################################################################

installGtest() {
  bilderInstall gtest ser
}


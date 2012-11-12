#!/bin/bash
#
# Version and build information for gperf
#
# $Id:%
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GPERF_BLDRVERSION=${GPERF_BLDRVERSION:-"2.7.2"}

######################################################################
#
# Other values
#
######################################################################

GPERF_BUILDS=${GPERF_BUILDS:-"ser,sersh"}
GPERF_DEPS=autotools

######################################################################
#
# Launch gperf builds.
#
######################################################################

buildgperf() {
  if bilderUnpack gperf; then
# Builds must be done separately
    if bilderConfig gperf ser "--enable-shared=no"; then
      bilderBuild gperf ser
    fi
    if bilderConfig gperf sersh "--enable-shared=yes"; then
      bilderBuild gperf sersh
    fi
  fi
}

######################################################################
#
# Test gperf
#
######################################################################

testgperf() {
  techo "Not testing gperf."
}

######################################################################
#
# Install gperf
#
######################################################################

installgperf() {
  bilderInstall gperf ser
  bilderInstall gperf sersh

  findContribPackage gperf gperf ser
}


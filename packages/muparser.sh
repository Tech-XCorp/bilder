#!/bin/bash
#
# Version and build information for muparser
#
# $Id: muparser.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MUPARSER_BLDRVERSION=${MUPARSER_BLDRVERSION:-"v134"}

######################################################################
#
# Other values
#
######################################################################

MUPARSER_BUILDS=${MUPARSER_BUILDS:-"ser,sersh"}
MUPARSER_DEPS=m4

######################################################################
#
# Launch muparser builds.
#
######################################################################

buildMuparser() {
  if bilderUnpack muparser; then
# Builds must be done separately
    if bilderConfig muparser ser "--enable-shared=no"; then
      bilderBuild muparser ser
    fi
    if bilderConfig muparser sersh "--enable-shared=yes"; then
      bilderBuild muparser sersh
    fi
  fi
}

######################################################################
#
# Test muparser
#
######################################################################

testMuparser() {
  techo "Not testing muparser."
}

######################################################################
#
# Install muparser
#
######################################################################

installMuparser() {
  bilderInstall muparser ser
  bilderInstall muparser sersh

  findContribPackage muparser muparser ser
}


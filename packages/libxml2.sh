#!/bin/bash
#
# Version and build information for libxml2
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LIBXML2_BLDRVERSION=${LIBXML2_BLDRVERSION:-"2.7.8"}

######################################################################
#
# Other values
#
######################################################################

LIBXML2_BUILDS=${LIBXML2_BUILDS:-"ser"}
LIBXML2_DEPS=m4

######################################################################
#
# Launch libxml2 builds.
#
######################################################################

buildLibxml2() {
  if bilderUnpack libxml2; then
    if bilderConfig libxml2 ser "--enable-shared=no"; then
      bilderBuild libxml2 ser
    fi
  fi
}

######################################################################
#
# Test libxml2
#
######################################################################

testLibxml2() {
  techo "Not testing libxml2."
}

######################################################################
#
# Install libxml2
#
######################################################################

installLibxml2() {
  bilderInstall libxml2 ser
  bilderInstall libxml2 sersh

  findContribPackage libxml2 libxml2 ser
}


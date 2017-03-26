#!/bin/sh
######################################################################
#
# @file    libxml2.sh
#
# @brief   Version and build information for libxml2.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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

LIBXML2_BUILDS=${LIBXML2_BUILDS:-"ser,sersh"}
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
    if bilderConfig libxml2 sersh "--enable-shared=yes"; then
      bilderBuild libxml2 sersh
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


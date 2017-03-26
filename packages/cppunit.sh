#!/bin/sh
######################################################################
#
# @file    cppunit.sh
#
# @brief   Version and build information for cppunit.
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

CPPUNIT_BLDRVERSION=${CPPUNIT_BLDRVERSION:-"1.12.1"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$CPPUNIT_BUILDS"; then
  CPPUNIT_BUILDS=ser
fi

CPPUNIT_DEPS=autotools
CPPUNIT_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch cppunit builds.
#
######################################################################

buildCppunit() {
  if bilderUnpack cppunit; then
    if bilderConfig cppunit ser; then
      bilderBuild cppunit ser
    fi
  fi
}

######################################################################
#
# Test cppunit
#
######################################################################

testCppunit() {
  techo "Not testing cppunit."
}

######################################################################
#
# Install cppunit
#
######################################################################

installCppunit() {
  bilderInstall cppunit ser
}

#!/bin/sh
######################################################################
#
# @file    qdstests.sh
#
# @brief   Version and build information for qdstests.
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

QDSTESTS_BLDRVERSION=${QDSTESTS_BLDRVERSION:-""}

# Built from svn only
######################################################################
#
# Other values
#
######################################################################

QDSTESTS_BUILDS=${QDSTESTS_BUILDS:-"ser"}
QDSTESTS_DEPS=autotools
QDSTESTS_UMASK=007
SOFTWARE_BEING_TESTED=quidsall
TESTSUITE_NAME=qdstests
RESULTS=

######################################################################
#
# Launch qdstests builds
#
######################################################################

QDSTESTS_SER_OTHER_ARGS="-DQUIDS=$PROJECT_DIR/ddsflow -DQUIDS_BUILD=$PROJECT_DIR/builds/ddsflow -DQUIDS_PROC=ser"

buildQdstests() {
  techo "start qdstests build"
  if bilderConfig -c qdstests ser "$BOOST_INCDIR_ARG  $QDSTESTS_SER_OTHER_ARGS"; then
    bilderBuild qdstests ser
  fi
}

######################################################################
#
# Test qdstests
#
######################################################################

testQdstests() {
  techo "Not testing qdstests yet."
#  bilderRunTests qdstests QdstestsTests
}

######################################################################
#
#  execute QdsTests
#
#####################################################################

testQuidsall() {
  techo "Testing quidsall."
  bilderRunTests  quidsall QdsTests
}

buildQdsTests() {
  techo "start quidsall testing"
  techo `pwd`
  techo "cd $PROJECT_DIR/builds/qdstests/ser/;./runTests.sh"
  (cd $PROJECT_DIR/builds/qdstests/ser/;./runTests.sh)

}

######################################################################
#
# Install qdstests
#
######################################################################

installQdstests() {
  techo "Not installing qdstests yet."
#  bilderInstall qdstests ser
}


#!/bin/bash
#
# Version and build information for tstests
#
# $Id: tstests.sh 6257 2012-06-20 18:30:41Z bala $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Builds and deps
#
######################################################################

TSTESTS_BUILDS=${TSTESTS_BUILDS:-"all"}
TSTESTS_DEPS=teaspink,$TEASPINK_DEPS

case $EMAIL_ARG in
  "-e vorpal-devel@ice.txcorp.com") EMAIL_ARG="-e developr-internal@txcorp.com";;
esac

######################################################################
#
# Configure and build
#
######################################################################

buildTsTests() {

# Define in terms of general variables for moving to a function
# This currently assumes only one test suite is being
# run at a time.  Will not generally be true.
  SOFTWARE_BEING_TESTED=teaspink
  TESTSUITE_NAME=tstests
  RESULTS=tsresults

# Get version see if testing
  if ! $TESTING; then
    return
  fi
  if ! test -d $PROJECT_DIR/$TESTSUITE_NAME; then
    techo "WARNING: PROJECT_DIR/$TESTSUITE_NAME does not exist.  Fix externals?"
    return
  fi
  getVersion $TESTSUITE_NAME
# If any builds of current version of software being tested are not
# installed, force tests
  local forcetests=`getForceTests $SOFTWARE_BEING_TESTED`
  if test -n "$forcetests"; then
    techo "Will run ${TESTSUITE_NAME}."
  fi
# Configure and run all tests
  if bilderPreconfig $forcetests $TESTSUITE_NAME; then
    if bilderConfig -i $forcetests $TESTSUITE_NAME all "--with-source-dir=$PROJECT_DIR/$SOFTWARE_BEING_TESTED --with-serial-dir=${BUILD_DIR}/$SOFTWARE_BEING_TESTED/ser --with-parallel-dir=${BUILD_DIR}/$SOFTWARE_BEING_TESTED/ser $CONFIG_SUPRA_SP_ARG $MPI_LAUNCHER_ARG $EMAIL_ARG $TSTESTS_ALL_OTHER_ARGS"; then
      case `uname` in
        CYGWIN*)
          local RUNTXTEST_OTHER_ARGS=-k
          ;;
      esac
      bilderBuild $TESTSUITE_NAME all "all runtests RUNTXTEST_OTHER_ARGS=$RUNTXTEST_OTHER_ARGS"
    fi
  fi

}

######################################################################
#
# Install.  Return whether tests succeeded
#
######################################################################

installTsTests() {
  waitTests $TESTSUITE_NAME ${SOFTWARE_BEING_TESTED}-txtest
  return $?
}


#!/bin/bash
#
# Version and build information for nimtests
#
# $Id$
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

NIMTESTS_BUILDS=${NIMTESTS_BUILDS:-"all"}
NIMTESTS_DEPS=autotools

######################################################################
#
# Configure and build
#
######################################################################

buildNimTests() {

# Get version see if testing
  if ! $TESTING; then
    return
  fi
  getVersion nimtests
# If any builds of current version of fluxgrid are not installed, force fgtests
  local forcetests=
  if ! areAllInstalled $nimversion-$NIMROD_BLDRVERSION $NIMROD_BUILDS; then
    forcetests=-f
    techo "Not all builds of current version of nimrod are installed."
    techo "Will force tests."
  fi
# Configure and run all tests
  if bilderPreconfig $forcetests nimtests; then
    local resdirarg=`findResultsDirArg -u nimtests nimresults $RESULTS_DIRSFX`
    if bilderConfig -i $forcetests nimtests all "--with-source-dir=$PROJECT_DIR/$nimversion --with-serial-dir=${BUILD_DIR}/$nimversion/ser --with-parallel-dir=${BUILD_DIR}/$nimversion/par $resdirarg $CONFIG_SUPRA_SP_ARG $MPI_LAUNCHER_ARG $EMAIL_ARG $NIMTESTS_ALL_OTHER_ARGS"; then
      if test -n "$resdirarg"; then
        bilderBuild nimtests all "all runtests"
      else
        techo "Unable to find results for nimtests.  Not running."
        testFailures="$testFailures nimtests"
        anyFailures="$anyFailures nimtests"
      fi
    fi
  fi

}

######################################################################
#
# Install fgtests.  Return whether tests succeeded
#
######################################################################

installNimTests() {
  waitTests nimtests $nimversion-txtest
  return $?
}

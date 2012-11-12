#!/bin/bash
#
# Version and build information for uetests
#
# $Id: uetests.sh 6891 2012-10-26 11:24:20Z cary $
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

UETESTS_BUILDS=${UETESTS_BUILDS:-"all"}
UETESTS_DEPS=autotools
UETESTS_TESTDATA=ueresults

# JRC: below is not thread safe
# TESTPROJ=uedge

######################################################################
#
# Configure and build
#
######################################################################

buildUeTests() {
# Get version see if testing
  if ! $TESTING; then
    return
  fi
  getVersion uetests
# If any builds of current version of uedge are not installed, force tests
  local forcetests=
  if ! areAllInstalled uedge-$UEDGE_BLDRVERSION $UEDGE_BUILDS; then
    forcetests=-f
    techo "Not all builds of current version of uedge are installed."
    techo "Will force tests."
  fi
# Configure and run all tests
  if bilderPreconfig $forcetests uetests; then
    if bilderConfig -i $forcetests uetests all "--with-source-dir=$PROJECT_DIR/uedge --with-serial-dir=${BUILD_DIR}/uedge/ser --with-parallel-dir=${BUILD_DIR}/uedge/par $CONFIG_SUPRA_SP_ARG $MPI_LAUNCHER_ARG $EMAIL_ARG $UETESTS_ALL_OTHER_ARGS"; then
      bilderBuild uetests all "all runtests"
    fi
  fi
}

######################################################################
#
# Install uetests.  Return whether tests succeeded
#
######################################################################

installUeTests() {
  cmd="waitTests uetests uedge-txtest"
  techo "$cmd"
  $cmd
  return $?
}


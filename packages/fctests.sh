#!/bin/bash
#
# Version and build information for fctests
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

FCTESTS_BUILDS=${FCTESTS_BUILDS:-"all"}
FCTESTS_DEPS=autotools
FCTESTS_TESTDATA=fcresults

# JRC: below is not thread safe
# TESTPROJ=facets

######################################################################
#
# Configure and build
#
######################################################################

buildFcTests() {

# Get version see if testing
  if ! $TESTING; then
    return
  fi
  getVersion fctests
# If any builds of current version of facets are not installed, force tests
  local forcetests=
  if ! areAllInstalled facets-$FACETS_BLDRVERSION $FACETS_BUILDS; then
    forcetests=-f
    techo "Not all builds of current version of facets are installed."
    techo "Will force tests."
  fi
# Configure and run all tests
  if bilderPreconfig $forcetests fctests; then
    if bilderConfig -i $forcetests fctests all "--with-source-dir=$PROJECT_DIR/facets --with-serial-dir=${BUILD_DIR}/facets/ser --with-parallel-dir=${BUILD_DIR}/facets/par $CONFIG_SUPRA_SP_ARG $MPI_LAUNCHER_ARG $EMAIL_ARG $FCTESTS_ALL_OTHER_ARGS"; then
      bilderBuild fctests all "all runtests"
    fi
  fi

}

######################################################################
#
# Install fctests.  Return whether tests succeeded
#
######################################################################

installFcTests() {
  waitNamedTest fctests facets-txtest
  return $?
}


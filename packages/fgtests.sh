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

FGTESTS_BUILDS=${FGTESTS_BUILDS:-"all"}
FGTESTS_DEPS=autotools
FGTESTS_TESTDATA=fgresults

# JRC: This is not thread safe
# TESTPROJ=fluxgrid

######################################################################
#
# Configure and build
#
######################################################################

buildFgTests() {

# Get version see if testing
  if ! $TESTING; then
    return
  fi
  getVersion fgtests
# If any builds of current version of fluxgrid are not installed, force fgtests
  local forcetests=
  if ! areAllInstalled fluxgrid-$FLUXGRID_BLDRVERSION $FLUXGRID_BUILDS; then
    forcetests=-f
    techo "Not all builds of current version of fluxgrid are installed."
    techo "Will force tests."
  fi
# Configure and run all tests
  if bilderPreconfig $forcetests fgtests; then
    if bilderConfig -i $forcetests fgtests all "--with-source-dir=$PROJECT_DIR/fluxgrid --with-serial-dir=${BUILD_DIR}/fluxgrid/ser $CONFIG_SUPRA_SP_ARG $MPI_LAUNCHER_ARG $EMAIL_ARG $FGTESTS_ALL_OTHER_ARGS"; then
      bilderBuild fgtests all "all runtests"
    fi
  fi

}

######################################################################
#
# Install fgtests.  Return whether tests succeeded
#
######################################################################

installFgTests() {
  waitTests fgtests fluxgrid-txtest
  return $?
}


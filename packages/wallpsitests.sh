#!/bin/bash
#
# Version and build information for wallpsitests
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

WALLPSITESTS_BUILDS=${WALLPSITESTS_BUILDS:-"all"}
WALLPSITESTS_DEPS=autotools
WALLPSITESTS_TESTDATA=wallpsiresults

######################################################################
#
# Configure and build
#
######################################################################

buildWallpsiTests() {
# Get version see if testing
  getVersion wallpsitests
  if ! $TESTING; then
    return
  fi
# If any builds of current version of wallpsidge are not installed, force tests
  local forcetests=
  if ! areAllInstalled wallpsi-$WALLPSI_BLDRVERSION $WALLPSI_BUILDS; then
    forcetests=-f
    techo "Not all builds of current version of wallpsi are installed."
    techo "Will force tests."
  fi
# Configure and run all tests
  if bilderPreconfig $forcetests wallpsitests; then
    if bilderConfig -i $forcetests wallpsitests all "--with-source-dir=$PROJECT_DIR/wallpsi --with-serial-dir=${BUILD_DIR}/wallpsi/ser $CONFIG_SUPRA_SP_ARG $MPI_LAUNCHER_ARG $EMAIL_ARG $WALLPSITESTS_ALL_OTHER_ARGS"; then
      bilderBuild wallpsitests all "all runtests"
    fi
  fi
}

######################################################################
#
# Install wallpsitests.  Return whether tests succeeded
#
######################################################################

installWallpsiTests() {
  cmd="waitTests wallpsitests wallpsi-txtest"
  techo "$cmd"
  $cmd
  return $?
}


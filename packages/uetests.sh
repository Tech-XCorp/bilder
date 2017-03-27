#!/bin/sh
######################################################################
#
# @file    uetests.sh
#
# @brief   Version and build information for uetests.
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
  cmd="waitNamedTest uetests uedge-txtest"
  techo "$cmd"
  $cmd
  return $?
}


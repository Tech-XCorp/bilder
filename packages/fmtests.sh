#!/bin/sh
######################################################################
#
# @file    fmtests.sh
#
# @brief   Documentation goes here.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

#!/bin/bash
#
# Version and build information for fctests
#
# $Rev$ $Date$
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

FMTESTS_BUILDS=${FMTESTS_BUILDS:-"all"}
# Add fmcfm deps to ensure redoing upon FMCFM rebuild
FMTESTS_DEPS=autotools
FMTESTS_TESTDATA=fmresults

# JRC: below is not threadsafe
# TESTPROJ=fmcfm

######################################################################
#
# Configure and build
#
######################################################################

buildFmTests() {
# Get version see if testing
  if ! $TESTING; then
    return
  fi
  getVersion fmtests
# If any builds of current version of fmcfm are not installed, force tests
  local forcetests=
  if ! areAllInstalled fmcfm-$FMCFM_BLDRVERSION $FMCFM_BUILDS; then
    forcetests=-f
    techo "Not all builds of current version of fmcfm are installed."
    techo "Will force tests."
  fi
# Configure and run all tests
  if bilderPreconfig $forcetests fmtests; then
    if bilderConfig -i $forcetests fmtests all "--with-source-dir=$PROJECT_DIR/fmcfm --with-serial-dir=${BUILD_DIR}/fmcfm/ser --with-parallel-dir=${BUILD_DIR}/fmcfm/par $CONFIG_SUPRA_SP_ARG $MPI_LAUNCHER_ARG $EMAIL_ARG $FMTESTS_ALL_OTHER_ARGS"; then
      bilderBuild fmtests all "all runtests"
    fi
  fi
}

######################################################################
#
# Install fmtests.  Return whether tests succeeded
#
######################################################################

installFmTests() {
  waitNamedTest fmtests fmcfm-txtest
  return $?
}


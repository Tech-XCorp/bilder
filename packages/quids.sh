#!/bin/bash
#
# Version and build information for quids
#
# $Id: quids.sh 6766 2012-09-28 20:52:55Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

QUIDS_BLDRVERSION=${QUIDS_BLDRVERSION:-""}

# Built from package only
######################################################################
#
# Other values
#
######################################################################

QUIDS_BUILDS=${QUIDS_BUILDS:-"ser"}
QUIDS_DEPS=cmake,Python,boost,opensplice,simd,autotools
QUIDS_UMASK=007

######################################################################
#
# Launch quids builds
#
######################################################################

buildQuids() {
  if bilderConfig -c quids ser "$BOOST_INCDIR_ARG $SIMD_INCDIR_ARG $CMAKE_SUPRA_SP_ARG $QUIDS_SER_OTHER_ARGS"; then
    bilderBuild quids ser
  fi
}

######################################################################
#
# Test quids must be driven from top level qdstests 
#
######################################################################


######################################################################
#
# Install quids
#
######################################################################

installQuids() {
  bilderInstall quids ser
}


#!/bin/bash
#
# Version and build information for ddsflow
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

DDSFLOW_BLDRVERSION=${DDSFLOW_BLDRVERSION:-""}

# Built from package only
######################################################################
#
# Other values
#
######################################################################

DDSFLOW_BUILDS=${DDSFLOW_BUILDS:-"ser"}
DDSFLOW_DEPS=cmake,Python,boost,opensplice,simd
DDSFLOW_UMASK=007

######################################################################
#
# Launch ddsflow builds
#
######################################################################

buildDdsflow() {
  techo "start ddsflow build"
  if bilderConfig -c ddsflow ser "$BOOST_INCDIR_ARG $SIMD_INCDIR_ARG $CMAKE_SUPRA_SP_ARG $DDSFLOW_SER_OTHER_ARGS"; then
    bilderBuild ddsflow ser
  fi
}

######################################################################
#
# Test ddsflow must be driven from top level qdstests 
#
######################################################################


######################################################################
#
# Install ddsflow
#
######################################################################

installDdsflow() {
  techo "start ddsflow install"
  bilderInstall ddsflow ser
}


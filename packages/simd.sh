#!/bin/bash
#
# Version and build information for simd
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SIMD_BLDRVERSION=${SIMD_BLDRVERSION:-"0.09"}

# Built from package only
######################################################################
#
# Other values
#
######################################################################

SIMD_BUILDS=${SIMD_BUILDS:-"ser"}
SIMD_DEPS=Python,boost,cmake,opensplice
SIMD_UMASK=007

######################################################################
#
# Launch simd builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildSimd() {
  if bilderUnpack simd; then
    if bilderConfig -c simd ser "$BOOST_INCDIR_ARG $SIMD_SER_OTHER_ARGS"; then
      bilderBuild simd ser
    fi
  fi
}


######################################################################
#
# Test simd
#
######################################################################

testSimd() {
  techo "Not testing simd."
}

######################################################################
#
# Install simd
#
######################################################################

installSimd() {
  bilderInstall simd ser
}



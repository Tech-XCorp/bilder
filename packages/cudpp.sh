#!/bin/bash
#
# Version and build information for cudpp
#
# $Id$
#
######################################################################

CUDPP_BLDRVERSION=${CUDPP_BLDRVERSION:-"1.1.1"}

######################################################################
#
# Other values
#
######################################################################

CUDPP_BUILDS=${CUDPP_BUILDS:-"gpu"}
#CUDPP_DEPS=cmake

#####################################################################
#
# Launch cudpp builds.
#
######################################################################

#buildCudpp() {
#  if bilderUnpack cudpp; then
#    if bilderConfig cudpp gpu "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CLAPACK_CMAKE_SER_OTHER_ARGS $TARBALL_NODEFLIB_FLAGS"; then
#      bilderBuild cudpp gpu
#    fi
#  fi
#}

######################################################################
#
# Test cudpp
#
######################################################################

#testCudpp() {
#  techo "Not testing cudpp."
#}

######################################################################
#
# Install cudpp
#
######################################################################

#installCudpp() {
#  bilderInstall cudpp gpu
#}


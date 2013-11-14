#!/bin/bash
#
# Version and build information for vsreader
#
# $Id: $
#
######################################################################

######################################################################
#
# Version
#
######################################################################
VSREADER_BLDRVERSION=${VSREADER_BLDRVERSION:-""}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VSREADER_DEPS=${VSREADER_DEPS:-"hdf5"}
VSREADER_DESIRED_BUILDS=${VSREADER_DESIRED_BUILDS:-"ser"}

computeBuilds vsreader

VSREADER_UMASK=007

######################################################################
#
# Launch vsreader builds
#
######################################################################

buildVsreader() {

  getVersion vsreader

# Standard sequence
  if bilderPreconfig -c vsreader; then
    if bilderConfig vsreader ser "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $CMAKE_LINLIB_SER_ARGS $VSREADER_SER_OTHER_ARGS"; then
      bilderBuild vsreader ser
    fi
  fi
}

######################################################################
#
# Test vsreader must be driven from top level
#
######################################################################

testVsreader() {
  techo "Not testing vsreader."
}

######################################################################
#
# Install vsreader
#
######################################################################

installVsreader() {
  bilderInstall vsreader ser
}

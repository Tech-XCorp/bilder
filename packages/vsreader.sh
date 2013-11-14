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
VSREADER_BUILDS=ser
if [[ `uname` =~ "CYGWIN" ]]; then
  VSREADER_BUILDS=sermd
fi

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
    if bilderConfig vsreader ser "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_SER_OTHER_ARGS"; then
      bilderBuild vsreader ser
    fi
    if bilderConfig vsreader sermd "-DUSE_TXBASE_SERMD:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_SER_OTHER_ARGS -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE"; then 
      bilderBuild vsreader sermd
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
  bilderInstall vsreader sermd
}

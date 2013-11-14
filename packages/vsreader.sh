#!/bin/bash
#
# Version and build information for vsreader
#
# $Id$
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


if [[ `uname` =~ "CYGWIN" ]]; then
  VSREADER_DESIRED_BUILDS=${VSREADER_DESIRED_BUILDS:-"sermd"}
  computeBuilds vsreader
else
  VSREADER_DESIRED_BUILDS=${VSREADER_DESIRED_BUILDS:-"ser"}
fi

VSREADER_UMASK=007
VSREADER_DEPS=hdf5

######################################################################
#
# Launch vsreader builds
#
######################################################################

buildVsreader() {

  getVersion vsreader

# Standard sequence
  if bilderPreconfig -c vsreader; then
    # use /MD on windows
    if bilderConfig vsreader ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_SER_OTHER_ARGS"; then
      bilderBuild vsreader ser
    fi
    if bilderConfig vsreader sermd "-DUSE_TXBASE_SERMD:BOOL=TRUE -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_SER_OTHER_ARGS"; then
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
  bilderInstall vsreader sermd
}

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

# VSREADER_BLDRVERSION=${VSREADER_BLDRVERSION:-""}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VSREADER_BUILDS=${VSREADER_DESIRED_BUILDS:-"$FORPYTHON_BUILD"}
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
  if ! bilderPreconfig -c vsreader; then
    return
  fi

# must use /MD on windows
  VSREADER_OTHER_ARGS=`deref VSREADER_${FORPYTHON_BUILD}_OTHER_ARGS`
  if bilderConfig vsreader $FORPYTHON_BUILD "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_OTHER_ARGS"; then
    bilderBuild vsreader $FORPYTHON_BUILD
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
  bilderInstall vsreader $FORPYTHON_BUILD
}

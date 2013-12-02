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

VSREADER_BUILDS=${VSREADER_DESIRED_BUILDS:-"${FORPYTHON_BUILD},sermd"}
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
  if [[ `uname` =~ CYGWIN ]]; then
    local HDF5_INSTALL_DIR=$MIXED_CONTRIB_DIR/hdf5-${HDF5-BLDRVERSION}-sermd
    VSREADER_SER_ADDL_ARGS="-DHdf5_ROOT_DIR:PATH=\'${HDF5_INSTALL_DIR}\'"
  fi

  VSREADER_OTHER_ARGS=`deref VSREADER_${FORPYTHON_BUILD}_OTHER_ARGS`
  if bilderConfig vsreader $FORPYTHON_BUILD "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_OTHER_ARGS"; then
    bilderBuild vsreader $FORPYTHON_BUILD
  fi
  if bilderConfig vsreader sermd "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_OTHER_ARGS"; then
    bilderBuild vsreader sermd
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

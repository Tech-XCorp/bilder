#!/bin/bash
#
# Build information for vsreader
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in vsreader_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/vsreader_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setVsreaderNonTriggerVars() {
  VSREADER_MASK=002
# This allows individual package control of testing
  VSREADER_TESTING=${VSREADER_TESTING:-"${TESTING}"}
# This allows individual package control over whether ctest is used
  VSREADER_USE_CTEST=${VSREADER_USE_CTEST:-"$BILDER_USE_CTEST"}
# This allows individual package control over ctest submission model
  VSREADER_CTEST_MODEL=${VSREADER_CTEST_MODEL:-"$BILDER_CTEST_MODEL"}
}
setVsreaderNonTriggerVars

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
    VSREADER_SER_ADDL_ARGS="-DHdf5_ROOT_DIR:PATH='${HDF5_INSTALL_DIR}'"
  fi

  VSREADER_4PY_OTHER_ARGS=`deref VSREADER_${FORPYTHON_BUILD}_OTHER_ARGS`
  if bilderConfig vsreader $FORPYTHON_BUILD "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_SUPRA_SP_ARG $VSREADER_4PY_OTHER_ARGS"; then
    bilderBuild vsreader $FORPYTHON_BUILD
  fi
  if bilderConfig vsreader sermd "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $VSREADER_SERMD_OTHER_ARGS"; then
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
  bilderInstallAll vsreader
}

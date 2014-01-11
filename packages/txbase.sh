#!/bin/bash
#
# Version and build information for txbase
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# NOTE: txbase is set to the following tarball version so that if a
# project does not have txbase as an external repo, then this tarball
# will be used instead. If you want to use the repo, make sure you have
# txbase an external.

TXBASE_BLDRVERSION=${TXBASE_BLDRVERSION:-"2.9.1-r516"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$TXBASE_DESIRED_BUILDS"; then
  TXBASE_DESIRED_BUILDS=ser,par,sersh
  if [[ `uname` =~ CYGWIN ]]; then
    TXBASE_DESIRED_BUILDS="${TXBASE_DESIRED_BUILDS},sermd"
  fi
  if echo $DOCS_BUILDS | egrep -q "(^|,)develdocs($|,)"; then
    TXBASE_DESIRED_BUILDS=$TXBASE_DESIRED_BUILDS,develdocs
  fi
fi
computeBuilds txbase
addCc4pyBuild txbase
TXBASE_DEPS=hdf5,Python,openmpi,cmake
# On Windows, boost needed for some math functions
if [[ `uname` =~ CYGWIN ]]; then
  TXBASE_DEPS=$TXBASE_DEPS,boost
fi
trimvar TXBASE_DEPS ','
TXBASE_MASK=002
TXBASE_CTEST_TARGET=${TXBASE_CTEST_TARGET:-"$BILDER_CTEST_TARGET"}

######################################################################
#
# Launch txbase builds.
#
######################################################################

buildTxbase() {

# Check for svn version or package
  if test -d $PROJECT_DIR/txbase; then
    getVersion txbase
    if ! bilderPreconfig -c txbase; then
      return
    fi
  else
    if ! bilderUnpack txbase; then
      return
    fi
  fi

# Use make -j, always set up submitting
  TXBASE_MAKE_ARGS="$TXBASE_MAKE_ARGS $TXBASE_MAKEJ_ARGS ${TXBASE_CTEST_TARGET}Start ${TXBASE_CTEST_TARGET}Build"

# All builds
  if bilderConfig -c txbase ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SER_OTHER_ARGS"; then
    bilderBuild txbase ser "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase sersh "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SERSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SERSH_OTHER_ARGS"; then
    bilderBuild txbase sersh "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase cc4py "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_HDF5_CC4PY_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_CC4PY_OTHER_ARGS"; then
    bilderBuild txbase cc4py "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $TXBASE_SER_OTHER_ARGS"; then
    bilderBuild txbase sermd "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_PAR_OTHER_ARGS"; then
    bilderBuild txbase par "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase parsh "-DENABLE_PARALLEL:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PARSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_PARSH_OTHER_ARGS"; then
    bilderBuild txbase parsh "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase ben "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $CMAKE_HDF5_BEN_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_BEN_OTHER_ARGS"; then
# ben builds not tested
    bilderBuild txbase ben "$TXBASE_MAKEJ_ARGS"
  fi

# Developer doxygen (develdocs) build
  if bilderConfig -I $DEVELDOCS_DIR txbase develdocs "-DCTEST_BUILD_TARGET:STRING=apidocs-force -DENABLE_DEVELDOCS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SER_OTHER_ARGS" txbase; then
    local DOX_MAKE_ARGS=
    if [[ `uname` =~ CYGWIN ]]; then
      DOX_MAKE_ARGS="-m nmake"
    fi
    bilderBuild $DOX_MAKE_ARGS txbase develdocs "$TXBASE_MAKE_ARGS"
  fi

}

######################################################################
#
# Test txbase
#
######################################################################

testTxbase() {
  bilderRunTests -bs -i ben txbase "" "${TXBASE_CTEST_TARGET}Test"
}

######################################################################
#
# Install txbase
#
######################################################################

installTxbase() {
  TXBASE_DEVELDOCS_INSTALL_TARGET=install-apidocs
  bilderInstallTestedPkg -r -i ben -p open txbase
}


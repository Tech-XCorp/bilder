#!/bin/sh
######################################################################
#
# @file    ntcc_transport.sh
#
# @brief   Version and build information for ntcc_transport.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

NTCC_TRANSPORT_BLDRVERSION=${NTCC_TRANSPORT_BLDRVERSION:-"1.0.5-r1382"}

######################################################################
#
# Builds and deps
#
######################################################################

NTCC_TRANSPORT_BUILDS=${NTCC_TRANSPORT_BUILDS:-"ser,par"}
NTCC_TRANSPORT_DEPS=$MPI_BUILD
NTCC_TRANSPORT_UMASK=002

######################################################################
#
# Launch ntcc_transport builds.
#
######################################################################

buildNtccTransportCM() {

# Svn repo if present, otherwise package
  # The tarball is in ftpkgs
  if test -d $PROJECT_DIR/ntcc_transport; then
    getVersion ntcc_transport
    bilderPreconfig -c ntcc_transport
    res=$?
  else
    bilderUnpack ntcc_transport
    res=$?
  fi

# Configure and build
  if test $res = 0; then
# Sri V.  Intrepid does not like the shared build, go static all the way?
    if bilderConfig -c ntcc_transport ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $FCIOWRAPPERS_SER_OTHER_ARGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild ntcc_transport ser $1
    fi
# We can get funny PMPI crashes if ntcc_transport built shared for parallel?
    if bilderConfig -c ntcc_transport par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_SER $FCIOWRAPPERS_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild ntcc_transport par
    fi
  fi

}

buildNtcc_transport() {
  buildNtccTransportCM
}

######################################################################
#
# Test ntcc_transport
#
######################################################################

testNtcc_transport() {
  techo "Not testing ntcc_transport."
}

######################################################################
#
# Install ntcc_transport
#
######################################################################

installNtcc_transport() {
  bilderInstall ntcc_transport ser ntcc_transport
  bilderInstall ntcc_transport par ntcc_transport-par
}


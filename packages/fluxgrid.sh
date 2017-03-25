#!/bin/sh
######################################################################
#
# @file    fluxgrid.sh
#
# @brief   Version and build information for fluxgrid.
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

######################################################################
#
# Other values
#
######################################################################

FLUXGRID_BUILDS=${FLUXGRID_BUILDS:-"ser"}
FLUXGRID_DEPS=fciowrappers,netlib_lite
#FLUXGRID_DEPS=fciowrappers,facetsifc,netlib_lite
FLUXGRID_UMASK=002

######################################################################
#
# Launch fluxgrid builds.
#
######################################################################

buildFluxgridCM() {
  getVersion fluxgrid
  case `uname` in
   Linux)
    FLUXGRID_SER_OTHER_ARGS="${FLUXGRID_SER_OTHER_ARGS} -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"
  esac
  if bilderPreconfig fluxgrid; then
    if bilderConfig -c fluxgrid ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $CMAKE_LINLIB_SER_ARGS $FLUXGRID_SER_OTHER_ARGS"; then
      bilderBuild fluxgrid ser
    fi
  fi
}

buildFluxgrid() {
  buildFluxgridCM
}

######################################################################
#
# Test fluxgrid
#
######################################################################

testFluxgrid() {
  bilderRunTests fluxgrid FgTests
}

######################################################################
#
# Install fluxgrid
#
######################################################################

installFluxgrid() {
  bilderInstallTestedPkg -r -p open fluxgrid FgTests
}


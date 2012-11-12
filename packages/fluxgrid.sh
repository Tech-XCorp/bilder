#!/bin/bash
#
# Version and build information for fluxgrid
#
# $Id: fluxgrid.sh 6107 2012-05-23 22:13:30Z kruger $
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


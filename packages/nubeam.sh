#!/bin/bash
#
# Version and build information for nubeam
#
# $Id$
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

NUBEAM_BUILDS=${NUBEAM_BUILDS:-"ser,par"}
NUBEAM_DEPS=plasma_state,pspline,netlib_lite,netcdf,hdf5
NUBEAM_UMASK=002

######################################################################
#
# Launch nubeam builds.
#
######################################################################

buildNubeam() {
  getVersion nubeam
  if bilderPreconfig nubeam; then
    case $FC in
      *gfortran*)
        NUBEAM_CONF_FFLAGS=${NUBEAM_CONF_FFLAGS:-"--with-extra-fflags=-fno-range-check --with-extra-fcflags=-fno-range-check"}
        ;;
    esac
# nubeam needs to be built shared for usage of interpolation in python.
# Disabling this is done by machines files.
# Order is longest to shortest to build
    if bilderConfig nubeam par "--enable-parallel $CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $NUBEAM_CONF_FFLAGS --disable-mdsplus $CONFIG_LINLIB_BEN_ARGS $NUBEAM_PAR_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      rm -f $BUILD_DIR/nubeam/par/compfailures.txt
      bilderBuild nubeam par 
    fi
    if bilderConfig nubeam ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $NUBEAM_CONF_FFLAGS --disable-mdsplus $CONFIG_LINLIB_SER_ARGS $NUBEAM_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      rm -f $BUILD_DIR/nubeam/ser/compfailures.txt
      bilderBuild nubeam ser
    fi
  fi
}

######################################################################
#
# Test nubeam
#
######################################################################

testNubeam() {
  techo "Not testing nubeam."
}

######################################################################
#
# Install nubeam
#
######################################################################

installNubeam() {
# Order is shortest to longest to build
  bilderInstall nubeam ser nubeam
  bilderInstall nubeam par nubeam-par
}


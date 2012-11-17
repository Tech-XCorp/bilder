#!/bin/bash
#
# Version and build information for genray
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Other values
#
######################################################################

GENRAY_BUILDS=${GENRAY_BUILDS:-"ser,par"}
GENRAY_DEPS=netcdf

######################################################################
#
# Launch genray builds.
#
######################################################################

buildGenray() {
  getVersion genray
  if bilderPreconfig genray; then
    bilderConfig genray par "--enable-parallel $CONFIG_COMPILERS_PAR $LAPACK_ARG $BLAS_LIB_CONFIG__ARG $GENRAY_PAR_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"
    bilderBuild genray par "$GENRAY_MAKEJ_ARGS"
    bilderConfig genray ser "$CONFIG_COMPILERS_SER $LAPACK_ARG $GENRAY_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"
    bilderBuild genray ser "$GENRAY_MAKEJ_ARGS"
  fi
}

######################################################################
#
# Test facets
#
######################################################################

# Set umask to allow only group to modify
testGenray() {
  techo "Not testing facets."
}

######################################################################
#
# Install facets
#
######################################################################

# Set umask to allow only group to use
installGenray() {
  bilderInstall genray par
  bilderInstall genray ser
}


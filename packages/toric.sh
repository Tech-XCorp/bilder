#!/bin/bash
#
# Version and build information for toric
#
# $Id: toric.sh 5209 2012-02-09 23:23:28Z dws $
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

TORIC_BUILDS=${TORIC_BUILDS:-"ser,par"}
TORIC_DEPS=openmpi,fciowrappers
TORIC_UMASK=002

######################################################################
#
# Launch toric builds.
#
######################################################################

buildToric() {
  getVersion toric
  if bilderPreconfig toric; then
# Need to add CXX on Cray due to our build system
# Need to add CC on intrepid to satisfy configure that we can link
# Fortran into a C code.
    local TORIC_CONFIG_COMPILERS_PAR="CC=$MPICC CXX=$MPICXX FC=$MPIFC F77=$MPIFC"
    if bilderConfig toric par "--enable-parallel $TORIC_CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $TORIC_PAR_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
#    bilderBuild toric par "$JMAKEARGS"
      bilderBuild toric par	# Cannot use JMAKEARGS since Fortran
    fi
    if bilderConfig toric ser "--disable-parallel $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $TORIC_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild toric ser	# Cannot use JMAKEARGS since Fortran
    fi
  fi
}

######################################################################
#
# Test facets
#
######################################################################

# Set umask to allow only group to modify
testToric() {
  techo "Not testing facets."
}

######################################################################
#
# Install facets
#
######################################################################

# Set umask to allow only group to use
installToric() {
  bilderInstall toric par toric-par
  bilderInstall toric ser toric
}

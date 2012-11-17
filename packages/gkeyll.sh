#!/bin/bash
#
# Version and build information for gkeyll
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GKEYLL_BLDRVERSION=${GKEYLL_BLDRVERSION:-"0.1.0"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$GKEYLL_BUILDS"; then
  GKEYLL_BUILDS=ser,par
fi
# Deps include autotools for configuring tests
GKEYLL_DEPS=lua,boost,luabind,txbase,petsc,openmpi,gsl
trimvar GKEYLL_DEPS ','

######################################################################
#
# Launch gkeyll builds.
#
######################################################################

buildGkeyll() {
  getVersion gkeyll
  bilderPreconfig -c gkeyll
  GKEYLL_MAKE_ARGS="$GKEYLL_MAKEJ_ARGS"

# Order is from longest to shortest to build
# Parallel build
    if bilderConfig -c gkeyll par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $GKEYLL_ALL_ADDL_ARGS $GKEYLL_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG" gkeyll; then
      bilderBuild gkeyll par "$GKEYLL_MAKEJ_ARGS"
    fi
# Serial build
    if bilderConfig -c gkeyll ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $GKEYLL_ALL_ADDL_ARGS $GKEYLL_SER_OTHER_ARGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG" gkeyll; then
      bilderBuild gkeyll ser "$GKEYLL_MAKEJ_ARGS"
    fi
}

######################################################################
#
# Test gkeyll
#
######################################################################

testGkeyll() {
  echo "Nothing to do"
}

######################################################################
#
# Install gkeyll
#
######################################################################

installGkeyll() {
  bilderInstallTestedPkg -p open gkeyll GkeyllTests
}


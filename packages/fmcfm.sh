#!/bin/bash
#
# Version and build information for fmcfm
#
# $Id: fmcfm.sh 6696 2012-09-19 17:59:21Z alexanda $
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

if test -z "$FMCFM_BUILDS"; then
  FMCFM_BUILDS=ser,par
fi
FMCFM_DEPS=gacode,ntcc_transport,fciowrappers,openmpi,autotools
FMCFM_UMASK=002

######################################################################
#
# Launch fmcfm builds.
#
######################################################################

# Build fmcfm using cmake
buildFmcfmCM() {
  getVersion fmcfm
  if bilderPreconfig -c fmcfm; then
# Order is from longest to shortest to build
# Parallel build
    if bilderConfig -c fmcfm par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_LINLIB_SER_ARGS $FMCFM_PAR_OTHER_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild fmcfm par "$JMAKEARGS"
    fi
# Serial build
    if bilderConfig -c fmcfm ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_LINLIB_SER_ARGS $FMCFM_SER_OTHER_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild fmcfm ser "$JMAKEARGS"
    fi

  fi
}


# For easy switching
buildFmcfm() {
  buildFmcfmCM
}

######################################################################
#
# Test fmcfm
#
######################################################################

testFmcfm() {
  bilderRunTests fmcfm FmTests
}

######################################################################
#
# Install fmcfm
#
######################################################################

installFmcfm() {
  bilderInstallTestedPkg -r -p open fmcfm FmTests
}


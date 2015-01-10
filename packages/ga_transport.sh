#!/bin/bash
#
# Version and build information for ga-transport
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
# Builds, deps, mask, auxdata, paths
#
######################################################################

GA_TRANSPORT_BUILDS=${GA_TRANSPORT_BUILDS:-"ser,par"}
GA_TRANSPORT_DEPS=$MPI_BUILD,fciowrappers
GA_TRANSPORT_UMASK=002

######################################################################
#
# Launch ga_transport builds.
#
######################################################################

buildGaTransport() {
  getVersion ga_transport
  if bilderPreconfig ga_transport; then
    if bilderConfig ga_transport ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $GA_TRANSPORT_SER_OTHER_ARGS --disable-shared --enable-static --disable-parallel $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild ga_transport ser
    fi
# We can get funny PMPI crashes if ga-transport built shared for parallel?
    if bilderConfig ga_transport par "$CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR --enable-parallel $GA_TRANSPORT_PAR_OTHER_ARGS --disable-shared --enable-static $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild ga_transport par
    fi
  fi
}

######################################################################
#
# Test ga_transport
#
######################################################################

testGaTransport() {
  techo "Not testing ga-transport."
}

######################################################################
#
# Install ga-transport
#
######################################################################

installGaTransport() {
  bilderInstall ga_transport ser ga_transport
  bilderInstall ga_transport par ga_transport-par
}


#!/bin/bash
#
# Version and build information for wallpsi
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

WALLPSI_BUILDS=${WALLPSI_BUILDS:-"ser"}
addBenBuild wallpsi
WALLPSI_DEPS=facetsifc,autotools
WALLPSI_UMASK=002

######################################################################
#
# Launch wallpsi builds.
#
######################################################################

buildWallpsi() {
  getVersion wallpsi
  if bilderPreconfig wallpsi; then
    if bilderConfig wallpsi ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $CONFIG_LDFLAGS $CONFIG_HDF5_SER_DIR_ARG $CONFIG_SUPRA_SP_ARG $WALLPSI_OTHER_ARGS"; then
      bilderBuild wallpsi ser
    fi
    if bilderConfig wallpsi ben "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR $CONFIG_LDFLAGS $CONFIG_HDF5_PAR_DIR_ARG $CONFIG_SUPRA_SP_ARG $WALLPSI_OTHER_ARGS"; then
      bilderBuild wallpsi ben
    fi
  fi
}

######################################################################
#
# Test wallpsi
#
######################################################################

testWallpsi() {
  bilderRunTests wallpsi WallpsiTests
}

######################################################################
#
# Install wallpsi
#
######################################################################

installWallpsi() {
  bilderInstallTestedPkg -r -p open wallpsi WallpsiTests
}


#!/bin/bash
#
# Version and build information for exodusii
#
# $Id: exodusii.sh 6364 2012-07-15 09:04:57Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################
EXODUSII_BLDRVERSION=${EXODUSII_BLDRVERSION:-"5.21"}


######################################################################
#
# Other values
#
######################################################################
EXODUSII_DEPS=${EXODUSII_DEPS:-"hdf5,netcdf"}
if test -z "$EXODUSII_BUILDS"; then
  EXODUSII_BUILDS=ser
fi

EXODUSII_DEPS=autotools
EXODUSII_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch exodusii builds.
#
######################################################################

buildExodusii() {
  if bilderUnpack exodusii; then
    if bilderConfig -c exodusii ser "$CMAKE_HDF5_SER_DIR_ARG $CMAKE_NETCDF_SER_DIR_ARG"; then
      bilderBuild exodusii ser
    fi
  fi
}

######################################################################
#
# Test exodusii
#
######################################################################

testExodusii() {
  techo "Not testing exodusii."
}

######################################################################
#
# Install exodusii
#
######################################################################

installExodusii() {
  bilderInstall exodusii ser
}

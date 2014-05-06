#!/bin/bash
#
# Version and build information for exodusii
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

EXODUSII_BLDRVERSION=${EXODUSII_BLDRVERSION:-"5.22b"}

######################################################################
#
# Other values
#
######################################################################

EXODUSII_DEPS=${EXODUSII_DEPS:-"hdf5,netcdf,cmake"}
if test -z "$EXODUSII_BUILDS"; then
  EXODUSII_BUILDS="ser"
fi
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
# Now updates on file change
  # find hdf5 and netcdf
  local HDF5_INSTALL_DIR="${MIXED_CONTRIB_DIR}/hdf5-${HDF5_BLDRVERSION}-ser"
  local NETCDF_INSTALL_DIR="${MIXED_CONTRIB_DIR}/netcdf-${NETCDF_BLDRVERSION}-ser"
  local EXODUSII_OTHER_ARGS="-DBUILD_TESTING:BOOL=false -DBUILD_SHARED_LIBS:BOOL=false  -DHDF5_ROOT_DIR:PATH=\'${HDF5_INSTALL_DIR}\' -DNETCDF_ROOT_DIR:PATH=\'${NETCDF_INSTALL_DIR}\'"
  case `uname` in
    CYGWIN*) EXODUSII_OTHER_ARGS="${EXODUSII_OTHER_ARGS} -DCMAKE_C_FLAGS:STRING=\'-DNOT_NETCDF4\'";;
  esac
  if bilderUnpack exodusii; then
    if bilderConfig -c exodusii ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG ${EXODUSII_OTHER_ARGS}"; then
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


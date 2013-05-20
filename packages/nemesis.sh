#!/bin/bash
#
# Version and build information for nemesis
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################
NEMESIS_BLDRVERSION=${NEMESIS_BLDRVERSION:-"5.22b"}


######################################################################
#
# Other values
#
######################################################################
NEMESIS_DEPS=${NEMESIS_DEPS:-"exodusii,hdf5,netcdf_cmake,cmake"}
if test -z "$NEMESIS_BUILDS"; then
  NEMESIS_BUILDS="par"
fi
NEMESIS_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch nemesis builds.
#
######################################################################

buildNemesis() {
# Now updates on file change
  # find hdf5 and netcdf_cmake
  local HDF5_INSTALL_DIR="${MIXED_CONTRIB_DIR}/hdf5-${HDF5_BLDRVERSION}-ser"
  local NETCDF_CMAKE_INSTALL_DIR="${MIXED_CONTRIB_DIR}/netcdf_cmake-${NETCDF_CMAKE_BLDRVERSION}-ser"
  local EXODUSII_INSTALL_DIR="${MIXED_CONTRIB_DIR}/exodusii-${EXODUSII_BLDRVERSION}-ser"
  local NEMESIS_OTHER_ARGS="-DBUILD_SHARED_LIBS:BOOL=false  -DEXODUSII_ROOT_DIR:PATH=\'${EXODUSII_INSTALL_DIR}\'  -DHDF5_ROOT_DIR:PATH=\'${HDF5_INSTALL_DIR}\' -DNETCDF_CMAKE_ROOT_DIR:PATH=\'${NETCDF_CMAKE_INSTALL_DIR}\'"
  case `uname` in
    CYGWIN*)
      local ZLIB_INSTALL_DIR="${MIXED_CONTRIB_DIR}/zlib-${ZLIB_BLDRVERSION}-ser"
      NEMESIS_OTHER_ARGS="${NEMESIS_OTHER_ARGS} -DZLIB_ROOT_DIR:PATH=\'${ZLIB_INSTALL_DIR}\'"
      ;;
  esac

  if bilderUnpack nemesis; then
    if bilderConfig -c nemesis par "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG ${NEMESIS_OTHER_ARGS}"; then
      bilderBuild nemesis par
    fi
  fi
}

######################################################################
#
# Test nemesis
#
######################################################################

testNemesis() {
  techo "Not testing nemesis."
}

######################################################################
#
# Install nemesis
#
######################################################################

installNemesis() {
  bilderInstall nemesis par
}

#!/bin/bash
#
# Version and build information for netcdf_cmake
#
#
######################################################################

NETCDF_UNAME=`uname`

######################################################################
#
# Version:
#
######################################################################

NETCDF_CMAKE_BLDRVERSION_STD="trunk"
NETCDF_CMAKE_BLDRVERSION_EXP=$NETCDF_CMAKE_BLDRVERSION_STD

######################################################################
#
# Other values
#
######################################################################

if test -z "$NETCDF_CMAKE_BUILDS"; then
    NETCDF_CMAKE_BUILDS="ser"
fi
NETCDF_CMAKE_DEPS="cmake,hdf5"
NETCDF_CMAKE_UMASK=002
CURL_BUILDS=${CURL_BUILDS:-"ser"}

######################################################################
#
# Launch netcdf builds.
#
######################################################################

buildNetcdf_Cmake() {

# Now updates on file change
  # check netcdf_cmake
  local HDF5_DIR="${MIXED_CONTRIB_DIR}/hdf5-${HDF5_BLDRVERSION}-ser"
  local NETCDF_CMAKE_OTHER_ARGS="-DBUILD_SHARED_LIBS:BOOL=OFF  -DENABLE_DAP:BOOL=OFF -DBUILD_UTILITIES:BOOL=ON -DHDF5_ROOT_DIR:PATH=\"${HDF5_DIR}\""
  case `uname` in
    CYGWIN*) NETCDF_CMAKE_OTHER_ARGS="${NETCDF_CMAKE_OTHER_ARGS} -DENABLE_NETCDF_4:BOOL=OFF";;
  esac
  if bilderUnpack netcdf_cmake; then
    if bilderConfig -c netcdf_cmake ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG ${NETCDF_CMAKE_OTHER_ARGS}"; then
      bilderBuild netcdf_cmake ser
    fi
  fi
}

######################################################################
#
# Test netcdf 
#
######################################################################

testNetcdf_Cmake() {
  techo "Not testing netcdf_cmake."
}


######################################################################
#
# Install netcdf
#
######################################################################

# Move the shared netcdf_cmake libraries to their legacy names.
# Allows shared and static to be installed in same place.
#
# 1: The installation directory
#
installNetcdf_Cmake() {
  local anyinstalled=false
  if bilderInstall netcdf_cmake $NETCDF_CMAKE_BUILDS; then
    anyinstalled=true
  fi
  return 0
}

#!/bin/bash
#
# Version and build information for netcdf
#
#
######################################################################

NETCDF_UNAME=`uname`

######################################################################
#
# Version:
#
######################################################################

NETCDF_BLDRVERSION_STD="4.3.1"
NETCDF_BLDRVERSION_EXP=$NETCDF_BLDRVERSION_STD

######################################################################
#
# Other values
#
######################################################################

if test -z "$NETCDF_BUILDS"; then
    NETCDF_BUILDS="ser"
fi
NETCDF_DEPS="cmake,hdf5"
NETCDF_UMASK=002
CURL_BUILDS=${CURL_BUILDS:-"ser"}

######################################################################
#
# Launch netcdf builds.
#
######################################################################

buildNetcdf() {

# Now updates on file change
  # check netcdf
  local HDF5_DIR="${MIXED_CONTRIB_DIR}/hdf5-${HDF5_BLDRVERSION}-ser"
  local NETCDF_OTHER_ARGS="-DNC_USE_STATIC_CRT:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF  -DENABLE_DAP:BOOL=OFF -DBUILD_UTILITIES:BOOL=OFF -DENABLE_NETCDF_4:BOOL=OFF"
# Something screws up the netcdf flags. We have to specify /MT manually.
# This will have to be done for all other builds as well.
  case `uname` in
    CYGWIN*) NETCDF_OTHER_ARGS="${NETCDF_OTHER_ARGS} -DCMAKE_C_FLAGS_RELEASE:STRING='/MT /O2 /Ob2 /D NDEBUG'";;
  esac
  if bilderUnpack netcdf; then
    if bilderConfig -c netcdf ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG ${NETCDF_OTHER_ARGS}"; then
      bilderBuild netcdf ser
    fi
  fi
}

######################################################################
#
# Test netcdf 
#
######################################################################

testNetcdf() {
  techo "Not testing netcdf."
}


######################################################################
#
# Install netcdf
#
######################################################################

# Move the shared netcdf libraries to their legacy names.
# Allows shared and static to be installed in same place.
#
# 1: The installation directory
#
installNetcdf() {
  local anyinstalled=false
  if bilderInstall netcdf $NETCDF_BUILDS; then
    anyinstalled=true
  fi
  return 0
}

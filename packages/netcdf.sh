#!/bin/bash
#
# Version and build information for netcdf
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/netcdf_aux.sh

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setNetcdfGlobalVars() {
  if test -z "$NETCDF_BUILDS"; then
    NETCDF_BUILDS=ser,sersh
    if [[ `uname` =~ CYGWIN ]]; then
      NETCDF_BUILDS=$NETCDF_BUILDS,sermd
    fi
    addCc4pyBuild netcdf
  fi
  NETCDF_DEPS="hdf5,cmake"
  NETCDF_UMASK=002
}
setNetcdfGlobalVars

######################################################################
#
# Launch netcdf builds.
#
######################################################################

buildNetcdf() {

  if ! bilderUnpack netcdf; then
    return
  fi

# Combine other desired flags
  local NETCDF_ADDL_ARGS="-DENABLE_DAP:BOOL=OFF -DBUILD_UTILITIES:BOOL=ON"

  case `uname` in
    CYGWIN*)
# JRC: netcdf-4 is disabled because of all the complications of finding
# hdf5-config.cmake, and then the fact that it has errors concerning the
# hdf5 library names (libhdf5.lib or hdf5.lib) which vary with version.
      # NETCDF_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=OFF"
# JRC: verified that -DNC_USE_STATIC_CRT:BOOL=ON is not enough.
# Below needed for 4.3.2.
      NETCDF_SER_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DCMAKE_C_FLAGS_RELEASE:STRING='/MT /O2 /Ob2 /D NDEBUG' -DENABLE_NETCDF_4:BOOL=OFF"
      NETCDF_SERSH_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=OFF"
      # NETCDF_SERMD_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=OFF"
      NETCDF_SERMD_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SERMD_CMAKE_DIR'"
      ;;
    Darwin)
      NETCDF_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"
      NETCDF_SER_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SER_CMAKE_DIR'"
      NETCDF_SERSH_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SERSH_CMAKE_DIR'"
      ;;
    Linux)
# On Linux netcdf 4.3.[0-2] does not get the order of hdf5 libraries correct
# for ser.  Will have to check new versions as they come along.
      case $NETCDF_BLDRVERSION in
        3.* | 4.3.[0-2])
          NETCDF_SER_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=OFF"
          ;;
        *)
          NETCDF_SER_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SER_CMAKE_DIR'"
          ;;
      esac
      NETCDF_SERSH_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SERSH_CMAKE_DIR'"
      ;;
  esac

# Serial build
  if bilderConfig -c netcdf ser "-DNC_USE_STATIC_CRT:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_SER_ADDL_ARGS $NETCDF_SER_OTHER_ARGS"; then
    bilderBuild netcdf ser
  fi

# Serial shared build
  if bilderConfig -c netcdf sersh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_SERSH_ADDL_ARGS $NETCDF_SERSH_OTHER_ARGS"; then
    bilderBuild netcdf sersh
  fi

# Serial shared runtime build
  if bilderConfig -c netcdf sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=OFF $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_SERMD_ADDL_ARGS $NETCDF_SERMD_OTHER_ARGS"; then
    bilderBuild netcdf sermd
  fi

# For python build
  if bilderConfig -c netcdf cc4py "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_ADDL_ARGS $NETCDF_CC4PY_OTHER_ARGS"; then
    bilderBuild netcdf cc4py
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
  bilderInstallAll netcdf
  findNetcdf
}


#!/bin/bash
#
# Build information for netcdf_cxx4
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
source $mydir/netcdf_cxx4_aux.sh

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setNetcdf_cxx4GlobalVars() {
  if test -z "$NETCDF_CXX4_BUILDS"; then
    NETCDF_CXX4_BUILDS=ser,sersh
    if [[ `uname` =~ CYGWIN ]]; then
      # NETCDF_CXX4_BUILDS=$NETCDF_CXX4_BUILDS,sermd
      NETCDF_CXX4_BUILDS=NONE
    fi
    addCc4pyBuild netcdf_cxx4
  fi
  NETCDF_CXX4_DEPS="netcdf,hdf5,cmake"
  NETCDF_CXX4_UMASK=002
}
setNetcdf_cxx4GlobalVars

######################################################################
#
# Launch netcdf_cxx4 builds.
#
######################################################################

buildNetcdf_cxx4() {

  if ! bilderUnpack netcdf_cxx4; then
    return
  fi

# Combine other desired args.  Last arg needed only for shared Linux, but
# not harmful to add.
  # local NETCDF_CXX4_ADDL_ARGS="-DENABLE_DAP:BOOL=OFF -DBUILD_UTILITIES:BOOL=ON -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"

if false; then
  case `uname` in
    CYGWIN*)
# JRC: netcdf_cxx4-4 is disabled because of all the complications of finding
# hdf5-config.cmake, and then the fact that it has errors concerning the
# hdf5 library names (libhdf5.lib or hdf5.lib) which vary with version.
      # NETCDF_CXX4_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=OFF"
# JRC: verified that -DNC_USE_STATIC_CRT:BOOL=ON is not enough.
# Below needed for 4.3.2.
      NETCDF_CXX4_SER_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DCMAKE_C_FLAGS_RELEASE:STRING='/MT /O2 /Ob2 /D NDEBUG' -DENABLE_NETCDF_CXX4_4:BOOL=OFF"
      NETCDF_CXX4_SERSH_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=OFF"
      # NETCDF_CXX4_SERMD_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=OFF"
      NETCDF_CXX4_SERMD_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SERMD_CMAKE_DIR'"
      ;;
    Darwin)
      NETCDF_CXX4_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"
      NETCDF_CXX4_SER_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SER_CMAKE_DIR'"
      NETCDF_CXX4_SERSH_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SERSH_CMAKE_DIR'"
      ;;
    Linux)
# On Linux netcdf_cxx4 4.3.[0-2] does not get the order of hdf5 libraries correct
# for ser.  Will have to check new versions as they come along.
      case $NETCDF_CXX4_BLDRVERSION in
        3.* | 4.3.[0-2])
          NETCDF_CXX4_SER_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=OFF"
          ;;
        *)
          NETCDF_CXX4_SER_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SER_CMAKE_DIR'"
          ;;
      esac
      NETCDF_CXX4_SERSH_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_SERSH_CMAKE_DIR'"
# MAKE_INSTALL_RPATH_USE_LINK_PATH seems not enough, so adding following
      NETCDF_CXX4_SERSH_ADDL_ARGS="${NETCDF_CXX4_SERSH_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,'$HDF5_SERSH_DIR/lib'"
      NETCDF_CXX4_CC4PY_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} -DENABLE_NETCDF_CXX4_4:BOOL=ON -DHDF5_DIR:PATH='$HDF5_CC4PY_CMAKE_DIR'"
      NETCDF_CXX4_CC4PY_ADDL_ARGS="${NETCDF_CXX4_CC4PY_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,'$HDF5_CC4PY_DIR/lib'"
      ;;
  esac
fi

# Serial build
  if bilderConfig netcdf_cxx4 ser "--disable-shared --enable-static $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_CXX4_SER_ADDL_ARGS $NETCDF_CXX4_SER_OTHER_ARGS"; then
    bilderBuild netcdf_cxx4 ser
  fi

# Serial shared build
  if bilderConfig  netcdf_cxx4 sersh "--enable-shared --disable-static $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_CXX4_SERSH_ADDL_ARGS $NETCDF_CXX4_SERSH_OTHER_ARGS"; then
    bilderBuild netcdf_cxx4 sersh
  fi

# Disabling as autotools
if false; then
# Serial shared runtime build
  if bilderConfig netcdf_cxx4 sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=OFF $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_CXX4_SERMD_ADDL_ARGS $NETCDF_CXX4_SERMD_OTHER_ARGS"; then
    bilderBuild netcdf_cxx4 sermd
  fi
fi

# For python build
  if bilderConfig netcdf_cxx4 cc4py "-DBUILD_SHARED_LIBS:BOOL=ON $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_CXX4_CC4PY_ADDL_ARGS $NETCDF_CXX4_CC4PY_OTHER_ARGS"; then
    bilderBuild netcdf_cxx4 cc4py
  fi

}

######################################################################
#
# Test netcdf_cxx4
#
######################################################################

testNetcdf_cxx4() {
  techo "Not testing netcdf_cxx4."
}

######################################################################
#
# Install netcdf_cxx4
#
######################################################################

# Move the shared netcdf_cxx4 libraries to their legacy names.
# Allows shared and static to be installed in same place.
#
# 1: The installation directory
#
installNetcdf_cxx4() {
  bilderInstallAll netcdf_cxx4
  findNetcdf_cxx4
}


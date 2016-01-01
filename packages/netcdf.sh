#!/bin/bash
#
# Build information for netcdf
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in netcdf_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/netcdf_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNetcdfNonTriggerVars() {
  NETCDF_UMASK=002
}
setNetcdfNonTriggerVars

######################################################################
#
# Launch netcdf builds.
#
######################################################################

buildNetcdf() {

  if ! bilderUnpack netcdf; then
    return
  fi

# Combine other desired args.  Last arg needed only for shared Linux, but
# not harmful to add.
  local NETCDF_ADDL_ARGS="-DENABLE_DAP:BOOL=OFF -DBUILD_UTILITIES:BOOL=ON"
  local NETCDF_SER_ADDL_ARGS=
  local NETCDF_SERSH_ADDL_ARGS=

  case `uname` in
    CYGWIN*)
# JRC: netcdf-4 is disabled because of all the complications of finding
# hdf5-config.cmake, and then the fact that it has errors concerning the
# hdf5 library names (libhdf5.lib or hdf5.lib) which vary with version.
      # NETCDF_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=OFF"
# JRC: verified that -DNC_USE_STATIC_CRT:BOOL=ON is not enough.
# Below needed for 4.3.2.
      NETCDF_SER_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DCMAKE_C_FLAGS_RELEASE:STRING='/MT /O2 /Ob2 /D NDEBUG' -DENABLE_NETCDF_4:BOOL=OFF   -DCMAKE_STATIC_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt' -DCMAKE_EXE_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt'"
      NETCDF_SERSH_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=OFF"
      # NETCDF_SERMD_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=OFF"
      NETCDF_SERMD_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DHDF5_DIR:PATH='$CMAKE_HDF5_SERMD_DIR'"
      NETCDF_PAR_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$CMAKE_HDF5_PAR_DIR'"
      ;;
    Darwin | Linux)
      NETCDF_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"
      NETCDF_SER_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$CMAKE_HDF5_SER_DIR'"
      NETCDF_SERSH_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$CMAKE_HDF5_SERSH_DIR'"
      NETCDF_PAR_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$CMAKE_HDF5_PAR_DIR'"
      NETCDF_PYCSH_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$CMAKE_HDF5_PYCSH_DIR'"
      NETCDF_ADDL_ARGS="$NETCDF_ADDL_ARGS -DENABLE_NETCDF_4:BOOL=ON -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"
      if [[ `uname` =~ Linux ]]; then
        NETCDF_ADDL_ARGS="$NETCDF_ADDL_ARGS -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
# MAKE_INSTALL_RPATH_USE_LINK_PATH seems not enough, so adding following
        NETCDF_SERSH_ADDL_ARGS="${NETCDF_SERSH_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,'$HDF5_SERSH_DIR/lib'"
        NETCDF_PYCSH_ADDL_ARGS="${NETCDF_PYCSH_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,'$HDF5_PYCSH_DIR/lib'"
      fi
# Hdf5 found most easily here by env var.
      local NETCDF_SER_ENV="HDF5_ROOT='$CMAKE_HDF5_SER_DIR'"
      local NETCDF_SERSH_ENV="HDF5_ROOT='$CMAKE_HDF5_SERSH_DIR'"
      local NETCDF_PAR_ENV="HDF5_ROOT='$CMAKE_HDF5_PAR_DIR'"
      local NETCDF_PYCSH_ENV="HDF5_ROOT='$CMAKE_HDF5_PYCSH_DIR'"
      ;;
  esac

# Serial build
  if bilderConfig -c netcdf ser "-DNC_USE_STATIC_CRT:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_SER_ADDL_ARGS $NETCDF_ADDL_ARGS $NETCDF_SER_OTHER_ARGS" "" "$NETCDF_SER_ENV"; then
    bilderBuild netcdf ser
  fi

# Serial shared build
  if bilderConfig -c netcdf sersh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_SERSH_ADDL_ARGS $NETCDF_ADDL_ARGS $NETCDF_SERSH_OTHER_ARGS" "" "$NETCDF_SER_ENV"; then
    bilderBuild netcdf sersh
  fi

# Serial build
  if bilderConfig -c netcdf par "-DNC_USE_STATIC_CRT:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_PARALLEL:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $MINGW_RC_COMPILER_FLAG $NETCDF_PAR_ADDL_ARGS $NETCDF_ADDL_ARGS $NETCDF_PAR_OTHER_ARGS" "" "$NETCDF_PAR_ENV"; then
    bilderBuild netcdf par
  fi

# Serial shared runtime build
  if bilderConfig -c netcdf sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=OFF $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_SERMD_ADDL_ARGS $NETCDF_ADDL_ARGS $NETCDF_SERMD_OTHER_ARGS" "" "$NETCDF_SERMD_ENV"; then
    bilderBuild netcdf sermd
  fi

# For python build
  if bilderConfig -c netcdf pycsh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_PYCSH_ADDL_ARGS $NETCDF_ADDL_ARGS $NETCDF_PYCSH_OTHER_ARGS" "" "$NETCDF_PYCSH_ENV"; then
    bilderBuild netcdf pycsh
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
}


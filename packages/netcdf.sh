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
  local NETCDF_ADDL_ARGS="-DENABLE_DAP:BOOL=OFF -DBUILD_UTILITIES:BOOL=ON -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"

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
    Darwin | Linux)
      NETCDF_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DENABLE_NETCDF_4:BOOL=ON -DCMAKE_EXE_LINKER_FLAGS:STRING=-ldl"
      NETCDF_SER_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$HDF5_SER_CMAKE_DIR'"
      NETCDF_SERSH_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$HDF5_SERSH_CMAKE_DIR'"
      NETCDF_PAR_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$HDF5_PAR_CMAKE_DIR'"
      NETCDF_CC4PY_ADDL_ARGS="${NETCDF_ADDL_ARGS} -DHDF5_DIR:PATH='$HDF5_CC4PY_CMAKE_DIR'"
      if [[ `uname` =~ Linux ]]; then
# MAKE_INSTALL_RPATH_USE_LINK_PATH seems not enough, so adding following
        NETCDF_SERSH_ADDL_ARGS="${NETCDF_SERSH_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,'$HDF5_SERSH_DIR/lib'"
        NETCDF_CC4PY_ADDL_ARGS="${NETCDF_CC4PY_ADDL_ARGS} -DCMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-rpath,'$HDF5_CC4PY_DIR/lib'"
      fi
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

# Serial build
  if bilderConfig -c netcdf par "-DNC_USE_STATIC_CRT:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_PARALLEL:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $MINGW_RC_COMPILER_FLAG $NETCDF_PAR_ADDL_ARGS $NETCDF_PAR_OTHER_ARGS"; then
    bilderBuild netcdf par
  fi

# Serial shared runtime build
  if bilderConfig -c netcdf sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=OFF $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_SERMD_ADDL_ARGS $NETCDF_SERMD_OTHER_ARGS"; then
    bilderBuild netcdf sermd
  fi

# For python build
  if bilderConfig -c netcdf cc4py "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_CC4PY_ADDL_ARGS $NETCDF_CC4PY_OTHER_ARGS"; then
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
}


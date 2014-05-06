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
source $mydir/netcdfaux.sh

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
  NETCDF_DEPS="cmake,hdf5"
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
  local NETCDF_ADDL_ARGS="-DENABLE_DAP:BOOL=OFF -DBUILD_UTILITIES:BOOL=OFF -DENABLE_NETCDF_4:BOOL=OFF"

# Relics
if false; then
  case `uname` in
    CYGWIN*)
      NETCDF_OTHER_ARGS="${NETCDF_OTHER_ARGS} -DCMAKE_C_FLAGS_RELEASE:STRING='/MT /O2 /Ob2 /D NDEBUG'"
      ;;
  esac
fi

# Serial build
  if bilderConfig -c netcdf ser "-DNC_USE_STATIC_CRT:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=OFF $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_ADDL_ARGS $NETCDF_SER_OTHER_ARGS"; then
    bilderBuild netcdf ser
  fi

# Serial shared build
  if bilderConfig -c netcdf sersh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_ADDL_ARGS $NETCDF_SERSH_OTHER_ARGS"; then
    bilderBuild netcdf sersh
  fi

# Serial shared runtime build
  if bilderConfig -c netcdf sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=OFF $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_ADDL_ARGS $NETCDF_SERMD_OTHER_ARGS"; then
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
}


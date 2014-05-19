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
    case `uname` in
      CYGWIN*) NETCDF_CXX4_BUILDS=NONE;;
      *) NETCDF_CXX4_BUILDS=ser,par;;  # Only parallel, with netcdf4 works
    esac
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

# netcdf location specified by cppflags!
  local nclsd=lib
  if test -d $NETCDF_SER_DIR/lib64; then
    nclsd=lib64
  fi
  NETCDF_CXX4_SER_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} CPPFLAGS=-I$NETCDF_SER_DIR/include LIBS=-lnetcdf LDFLAGS=-L$NETCDF_SER_DIR/$nclsd"
  NETCDF_CXX4_PAR_ADDL_ARGS="${NETCDF_CXX4_ADDL_ARGS} CPPFLAGS=-I$NETCDF_PAR_DIR/include LIBS=-lnetcdf LDFLAGS=-L$NETCDF_PAR_DIR/$nclsd"

# Serial build
  if bilderConfig netcdf_cxx4 ser "--disable-shared --enable-static $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_CXX4_SER_ADDL_ARGS $NETCDF_CXX4_SER_OTHER_ARGS"; then
    bilderBuild netcdf_cxx4 ser
  fi

# Parallel build
  if bilderConfig netcdf_cxx4 par "--disable-shared --enable-static $CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $MINGW_RC_COMPILER_FLAG $NETCDF_CXX4_PAR_ADDL_ARGS $NETCDF_CXX4_PAR_OTHER_ARGS"; then
    bilderBuild netcdf_cxx4 par
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
}


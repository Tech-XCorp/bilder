#!/bin/bash
#
# Version and build information for pynetcdf4:
#   NOTE: On the web this is called netCDF4, but I've renamed it for
#   bilder because the difference between netcdf4 and netCDF4 is
#   ridiculously confusing.  The web page is here:
#   http://netcdf4-python.googlecode.com/svn/trunk/docs/netCDF4-module.html
#
# $Id$
#
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYNETCDF4_BLDRVERSION=${PYNETCDF4_BLDRVERSION:-"0.9.9"}

######################################################################
#
# Other values
#
######################################################################

PYNETCDF4_BUILDS=${PYNETCDF4_BUILDS:-"pycsh"}
PYNETCDF4_DEPS=netcdf,hdf5,numpy,Cython,numexpr
PYNETCDF4_UMASK=002

######################################################################
#
# Launch pynetcdf4 builds.
#
######################################################################

buildPynetcdf4() {
  if bilderUnpack pynetcdf4; then
    techo "Running bilderDuBuild for pynetcdf4."

# Remove all old installations
    for i in pynetcdf4; do
      cmd="rmall ${PYTHON_SITEPKGSDIR}/${i}*"
      techo "$cmd"
      $cmd
    done

# Look for HDF5 first by defines
    local PYNETCDF4_HDF5_DIR="$HDF5_PYCSH_DIR"
    if test -z "$PYNETCDF4_HDF5_DIR"; then
      techo "Cannot find hdf5.  Cannot build pynetcdf4."
      return 1
    fi
# Look for netcdf4 first by defines
    local PYNETCDF4_NETCDF_DIR="$NETCDF_PYCSH_DIR"
    if test -z "$PYNETCDF4_NETCDF_DIR"; then
      if test -d "$CONTRIB_DIR/netcdf-pycsh"; then
         PYNETCDF4_NETCDF_DIR=$CONTRIB_DIR/netcdf-pycsh
      else
        techo "Cannot find netcdf4.  Cannot build pynetcdf4."
        return 1
      fi
    fi
# pynetcdf4 uses environment variables rather than command-line 
# arguments.  Urgh.
    PYNETCDF4_ENV="HDF5_DIR=$PYNETCDF4_HDF5_DIR NETCDF4_DIR=$PYNETCDF4_NETCDF_DIR"

# Global for use by install
    PYNETCDF4_HDF5_VERSION=`echo $HDF5_PYCSH_DIR | sed -e 's/^.*hdf5-//' -e 's/-.*$//'`
    techo "PYNETCDF4_HDF5_VERSION = $PYNETCDF4_HDF5_VERSION."

    bilderDuBuild -p pynetcdf4 pynetcdf4 "$PYNETCDF4_ARGS" "$PYNETCDF4_ENV"
  fi
}

######################################################################
#
# Test pynetcdf4
#
######################################################################

testPynetcdf4() {
  techo "Not testing pynetcdf4."
}

######################################################################
#
# Function to put rpath in front of a library name in a dylib
# and add . to the rpath.  This will likely be generalized.
#
######################################################################

addDarwinRpathToDynLib() {
# Get the directory
  local dir=$1
  local extensions=`find $dir -name 'netCDF4.so' -print`
  for i in $extensions; do
    cmd="install_name_tool -change libhdf5.${PYNETCDF4_HDF5_VERSION}.dylib @rpath/libhdf5.${PYNETCDF4_HDF5_VERSION}.dylib $i"
    techo "$cmd"
    $cmd

    cmd="install_name_tool -change libhdf5_hl.${PYNETCDF4_HDF5_VERSION}.dylib @rpath/libhdf5_hl.${PYNETCDF4_HDF5_VERSION}.dylib $i"
    techo "$cmd"
    $cmd

    cmd="install_name_tool -add_rpath $HDF5_PYCSH_DIR/lib $i"
    techo "$cmd"
    $cmd

  done
}


######################################################################
#
# Install pynetcdf4
#
######################################################################

installPynetcdf4() {

# On CYGWIN, no installation to do, just mark
  local anyinstalled=false
  case `uname`-`uname -r` in
    CYGWIN*)
      bilderDuInstall -n pynetcdf4
      ;;
    Darwin-10.*)
    PYNETCDF4_TARGET_INSTALL_DIR="$PYTHON_SITEPKGSDIR/pynetcdf4"
    PYNETCDF4_ARGS="--install-purelib=$PYNETCDF4_TARGET_INSTALL_DIR --install-platlib=$PYNETCDF4_TARGET_INSTALL_DIR --install-scripts=$PYNETCDF4_TARGET_INSTALL_DIR --install-data=$PYNETCDF4_TARGET_INSTALL_DIR"
# On Darwin, add the rpaths so that hdf5 is found
      if bilderDuInstall pynetcdf4 "$PYNETCDF4_ARGS" "$PYNETCDF4_ENV"; then
        addDarwinRpathToDynLib "$PYNETCDF4_TARGET_INSTALL_DIR"
      fi
      ;;
    *)
      bilderDuInstall pynetcdf4 "$PYNETCDF4_ARGS" "$PYNETCDF4_ENV"
      ;;
  esac
}


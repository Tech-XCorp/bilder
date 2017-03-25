#!/bin/sh
######################################################################
#
# @file    netcdf_aux.sh
#
# @brief   Trigger vars and find information for netcdf.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setNetcdfTriggerVars() {
  NETCDF_BLDRVERSION_STD="4.3.2"
  NETCDF_BLDRVERSION_EXP="4.3.3.1"
  if test -z "$NETCDF_BUILDS"; then
# netcdf_cxx4 requires a parallel build
    NETCDF_BUILDS=ser,par,sersh
    case `uname` in
      CYGWIN*) ;; # par, sermd not building
      *) NETCDF_BUILDS=${NETCDF_BUILDS},par;;
    esac
    addPycshBuild netcdf
  fi
  NETCDF_DEPS="hdf5,cmake"
}
setNetcdfTriggerVars

######################################################################
#
# Find netcdf
#
######################################################################

findNetcdf() {

# Find installation directories
  findContribPackage Netcdf netcdf ser sersh par pycsh
  local builds="ser pycst sersh pycsh"
  if [[ `uname` =~ CYGWIN ]]; then
    findContribPackage Netcdf netcdf sermd
    builds="$builds sermd"
  fi
  techo

# Don't try to find pycst build of netcdf because sermd doesn't build on
# Windows. See above.
  # findPycstDir Netcdf
  findPycshDir Netcdf

# Find cmake configuration directories
  techo
  for bld in $builds; do
    local blddirvar=`genbashvar NETCDF_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/share/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar NETCDF_${bld}`_CMAKE_DIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar NETCDF_${bld}`_CMAKE_DIR_ARG
      eval $varname="\"-DNetcdf_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done

}


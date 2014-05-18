#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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
  NETCDF_BLDRVERSION_STD="4.3.1"
  NETCDF_BLDRVERSION_EXP="4.3.2"
  if test -z "$NETCDF_BUILDS"; then
# netcdf_cxx4 requires a parallel build
    NETCDF_BUILDS=ser,sersh,par
    case `uname` in
      CYGWIN*) ;; # par, sermd not building
      *) NETCDF_BUILDS=${NETCDF_BUILDS},par;;
    esac
    addCc4pyBuild netcdf
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
  findContribPackage Netcdf netcdf ser sersh par cc4py
  local builds="ser sersh cc4py"
  if [[ `uname` =~ CYGWIN ]]; then
    findContribPackage Netcdf netcdf sermd
    builds="$builds sermd"
  fi
  findCc4pyDir Netcdf

# Find cmake configuration directories
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


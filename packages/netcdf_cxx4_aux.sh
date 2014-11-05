#!/bin/bash
#
# Version and find information for netcdf_cxx4
#
# $Id$
#
######################################################################

######################################################################
#
# Get the version
#
######################################################################

getNetcdf_cxx4Version() {
  NETCDF_CXX4_BLDRVERSION_STD="4.2"
  NETCDF_CXX4_BLDRVERSION_EXP="4.2"
}
getNetcdf_cxx4Version

######################################################################
#
# Find netcdf_cxx4
#
######################################################################

findNetcdf_cxx4() {

# Find installation directories
  findContribPackage Netcdf_cxx4 netcdf_cxx4 ser par
  local builds="ser sersh pycsh"
  # if [[ `uname` =~ CYGWIN ]]; then
    # findContribPackage Netcdf_cxx4 netcdf_cxx4 sermd
    # builds="$builds sermd"
  # fi
  # findCc4pyDir Netcdf_cxx4

# Find cmake configuration directories
  for bld in $builds; do
    local blddirvar=`genbashvar NETCDF_CXX4_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/share/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar NETCDF_CXX4_${bld}`_CMAKE_DIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar NETCDF_CXX4_${bld}`_CMAKE_DIR_ARG
      eval $varname="\"-DNetcdf_cxx4_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done

}


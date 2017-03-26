#!/bin/sh
######################################################################
#
# @file    netcdf_fortran_aux.sh
#
# @brief   Trigger vars and find information for netcdf_fortran.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Get the version
#
######################################################################
getNetcdf_fortranVersion() {
  NETCDF_FORTRAN_BLDRVERSION_STD="4.2"
  NETCDF_FORTRAN_BLDRVERSION_EXP="4.2"
}
getNetcdf_fortranVersion

######################################################################
#
# Find netcdf_fortran
#
######################################################################

findNetcdf_fortran() {

# Find installation directories
  findContribPackage Netcdf_fortran netcdff ser sersh par
  local builds="ser sersh pycsh"
  # if [[ `uname` =~ CYGWIN ]]; then
    # findContribPackage Netcdf_fortran netcdf_fortran sermd
    # builds="$builds sermd"
  # fi
  # findPycshDir Netcdf_fortran

# Find cmake configuration directories
  for bld in $builds; do
    local blddirvar=`genbashvar NETCDF_FORTRAN_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/share/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar NETCDF_FORTRAN_${bld}`_CMAKE_DIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar NETCDF_FORTRAN_${bld}`_CMAKE_DIR_ARG
      eval $varname="\"-DNetcdf_fortran_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}

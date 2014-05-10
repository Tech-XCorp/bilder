#!/bin/bash
#
# Version and find information for netcdf
#
# $Id$
#
######################################################################

#
# Get the version
#
getNetcdfVersion() {
  NETCDF_BLDRVERSION_STD="4.3.1"
  NETCDF_BLDRVERSION_EXP="4.3.2"
}
getNetcdfVersion

#
# Find netcdf
#
findNetcdf() {

# Find installation directories
  findContribPackage Netcdf netcdf ser
  local builds="ser par"
  case `uname` in
    CYGWIN*)
      findContribPackage Netcdf netcdf sermd sersh cc4py
      builds="$builds sermd sersh cc4py"
      ;;
    *)
      findContribPackage Netcdf netcdf sersh cc4py
      builds="$builds sersh cc4py"
      ;;
  esac
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


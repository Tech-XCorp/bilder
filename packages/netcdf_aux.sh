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
  findContribPackage netcdf netcdf ser par
  case `uname` in
    CYGWIN*) echo "Not finding cc4py netcdf on CYGWIN";;
    *) findContribPackage netcdf netcdf cc4py;;
  esac
  findCc4pyDir netcdf
}


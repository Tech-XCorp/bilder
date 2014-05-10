#!/bin/bash
#
# Version and build information for hdf5
#
# $Id$
#
# For mingw: http://www.swarm.org/index.php/Swarm_and_MinGW#HDF5_.28Optional.29
#
######################################################################

######################################################################
#
# Version:
#
######################################################################

getHdf5Version() {
  case `uname` in
    CYGWIN*)
# If you upgrade to a newer version of hdf5, first check a parallel run on
# 32-bit Windows and be sure it does not crash.
      if [[ "$CC" =~ mingw ]]; then
        HDF5_BLDRVERSION_STD=1.8.10
      else
        HDF5_BLDRVERSION_STD=1.8.12
      fi
      ;;

    Darwin)
      case `uname -r` in
        13.*) HDF5_BLDRVERSION_STD=1.8.9;;	# Mavericks
           *) HDF5_BLDRVERSION_STD=1.8.12;;	# Everything else
      esac
      ;;

    Linux) HDF5_BLDRVERSION_STD=1.8.12;;
  esac
  HDF5_BLDRVERSION_EXP=1.8.12
}
getHdf5Version

######################################################################
#
# Find hdf5
#
######################################################################

findHdf5() {
  findContribPackage Hdf5 hdf5 ser par
  case `uname` in
    CYGWIN*)
      findContribPackage Hdf5 hdf5dll sersh parsh sermd cc4py
      ;;
    *)
      findContribPackage Hdf5 hdf5 sersh parsh cc4py
      ;;
  esac
  findCc4pyDir Hdf5
}


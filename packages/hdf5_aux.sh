#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
# For mingw: http://www.swarm.org/index.php/Swarm_and_MinGW#HDF5_.28Optional.29
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

getHdf5TriggerVars() {

# Set the version
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
  HDF5_BLDRVERSION_EXP=1.8.13

# Set the builds.
  if test -z "$HDF5_DESIRED_BUILDS"; then
    HDF5_DESIRED_BUILDS=ser,par,sersh
# No need for parallel shared, as MPI executables are built static.
    case `uname`-${BILDER_CHAIN} in
      CYGWIN*)
        HDF5_DESIRED_BUILDS="$HDF5_DESIRED_BUILDS,sermd"
        if test "$VISUALSTUDIO_VERSION" = "10"; then
# Python built with VS9, so need hdf5 build for that
          HDF5_DESIRED_BUILDS="$HDF5_DESIRED_BUILDS,pycsh"
        fi
        ;;
    esac
  fi
  computeBuilds hdf5
  addPycshBuild hdf5

# Deps and other
  HDF5_DEPS=${MPI_BUILD},zlib,cmake,bzip2

}
getHdf5TriggerVars

######################################################################
#
# Find hdf5
#
######################################################################

findHdf5() {

# Find installation directories
  local srchbuilds="ser par"
  case `uname` in
    CYGWIN*)
      srchbuilds="$srchbuilds sermd"
      case $HDF5_BLDRVERSION in
        1.8.[0-9]) findContribPackage Hdf5 hdf5dll sersh parsh pycsh;;
        *) srchbuilds="$srchbuilds sersh parsh pycsh";;
      esac
      ;;
    *)
      srchbuilds="$srchbuilds sersh parsh pycsh"
      ;;
  esac
  findContribPackage Hdf5 hdf5 $srchbuilds
  findPycstDir Hdf5
  findPycshDir Hdf5

# Find cmake configuration directories
  for bld in $srchbuilds; do
    local blddirvar=`genbashvar HDF5_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      for subdir in share/cmake/hdf5 share/cmake/hdf5-${HDF5_BLDRVERSION} lib/cmake/hdf5-${HDF5_BLDRVERSION}; do
        if test -d $blddir/$subdir; then
          local dir=$blddir/$subdir
          if [[ `uname` =~ CYGWIN ]]; then
            dir=`cygpath -am $dir`
          fi
          local varname=`genbashvar HDF5_${bld}`_CMAKE_DIR
          eval $varname=$dir
          printvar $varname
          varname=`genbashvar HDF5_${bld}`_CMAKE_DIR_ARG
          eval $varname="\"-DHdf5_DIR:PATH='$dir'\""
          printvar $varname
          break
        fi
      done
    fi
  done

# Add to path
  addtopathvar PATH $CONTRIB_DIR/hdf5/bin

}


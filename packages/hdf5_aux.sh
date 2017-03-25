#!/bin/sh
######################################################################
#
# @file    hdf5_aux.sh
#
# @brief   Trigger vars and find information for hdf5.
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

getHdf5TriggerVars() {

  case `uname` in
    CYGWIN*)
# 1.8.{16,18} crash on Windows
      HDF5_BLDRVERSION_STD=${HDF5_BLDRVERSION_STD:-"1.8.13"}
      HDF5_BLDRVERSION_EXP=${HDF5_BLDRVERSION_EXP:-"1.8.13"}
      ;;
    *)
      HDF5_BLDRVERSION_STD=${HDF5_BLDRVERSION_STD:-"1.8.18"}
      HDF5_BLDRVERSION_EXP=${HDF5_BLDRVERSION_EXP:-"1.8.18"}
      ;;
  esac

# Set the builds.
  if test -z "$HDF5_DESIRED_BUILDS"; then
    HDF5_DESIRED_BUILDS=ser,sersh,par
# No need for parallel shared, as MPI executables are built static.
    case `uname`-${BILDER_CHAIN} in
      CYGWIN*)
        HDF5_DESIRED_BUILDS="$HDF5_DESIRED_BUILDS,sermd"
        ;;
    esac
  fi
  computeBuilds hdf5
  addPycstBuild hdf5
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
      srchbuilds="$srchbuilds pycst sersh parsh pycsh"
      ;;
  esac
  findContribPackage Hdf5 hdf5 $srchbuilds
  techo
  findPycstDir Hdf5
  findPycshDir Hdf5

# Find cmake configuration directories
  techo
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


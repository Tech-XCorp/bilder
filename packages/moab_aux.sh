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

setMoabTriggerVars() {
  MOAB_REPO_URL=https://bitbucket.org/cadg4/moab.git
  MOAB_REPO_BRANCH_STD=master
  MOAB_REPO_BRANCH_EXP=master
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_UPSTREAM_BRANCH=master
  if test -z "$MOAB_DESIRED_BUILDS"; then
# Static serial and parallel builds needed for ulixes,
# Python static build needed for composers
# Python shared build for dagmc
    MOAB_DESIRED_BUILDS=ser,par
  fi
  computeBuilds moab
  if ! [[ `uname` =~ CYGWIN ]]; then
# Neither pycmd nor pycsh working on Windows
    addPycstBuild moab
    addPycshBuild moab
  fi
  MOAB_DEPS=cmake,hdf5,netcdf
  if [[ $MOAB_BUILDS =~ par ]]; then
    MOAB_DEPS=$MOAB_DEPS,trilinos
  fi
}
setMoabTriggerVars

######################################################################
#
# Find moab
#
######################################################################

findMoab() {
  srchbuilds="ser pycst sersh pycsh par"
  findPackage Moab MOAB "$BLDR_INSTALL_DIR" $srchbuilds
  techo
  findPycshDir Moab
  findPycstDir Moab
  addtopathvar PATH ${MOAB_PYCSH_DIR}/bin
  techo
# Find cmake configuration directories
  for bld in $srchbuilds; do
    local blddirvar=`genbashvar MOAB_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      for subdir in lib; do
        if test -d $blddir/$subdir; then
          local dir=$blddir/$subdir
          if [[ `uname` =~ CYGWIN ]]; then
            dir=`cygpath -am $dir`
          fi
          local varname=`genbashvar MOAB_${bld}`_CMAKE_DIR
          eval $varname=$dir
          printvar $varname
          varname=`genbashvar MOAB_${bld}`_CMAKE_DIR_ARG
          eval $varname="\"-DHdf5_DIR:PATH='$dir'\""
          printvar $varname
          break
        fi
      done
    fi
  done
}



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
  MOAB_REPO_BRANCH_STD=fixAddScimake
  MOAB_REPO_BRANCH_EXP=fixAddScimake
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_UPSTREAM_BRANCH_STD=master
  MOAB_UPSTREAM_BRANCH_EXP=master
  if test -z "$MOAB_DESIRED_BUILDS"; then
# Static serial and parallel builds needed for ulixes,
    MOAB_DESIRED_BUILDS=ser,par
# Python shared build needed for composers
# Python shared build needed for dagmc
    if ! [[ `uname` =~ CYGWIN ]]; then
      MOAB_DESIRED_BUILDS=${MOAB_DESIRED_BUILDS},${FORPYTHON_SHARED_BUILD}
    fi
  fi
  computeBuilds moab
  MOAB_DEPS=autotools,cgm,netcdf
  if [[ $MOAB_BUILDS =~ par ]]; then
    MOAB_DEPS=$MOAB_DEPS,trilinos
    if test -z "$TRILINOS_DESIRED_BUILDS"; then
      TRILINOS_DESIRED_BUILDS=sercommio,parcommio
    else
      TRILINOS_BUILDS=sercommio,parcommio
    fi
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
  if test -n "$MOAB_PYCSH_DIR"; then
    addtopathvar PATH ${MOAB_PYCSH_DIR}/bin
  fi
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



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
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_REPO_BRANCH_STD=master
  MOAB_REPO_BRANCH_EXP=master
  MOAB_BUILD=$FORPYTHON_SHARED_BUILD
  MOAB_BUILDS=${MOAB_BUILDS:-"$FORPYTHON_SHARED_BUILD,par"}
  MOAB_DEPS=cgm,netcdf,trilinos
}
setMoabTriggerVars

######################################################################
#
# Find moab
#
######################################################################

findMoab() {
  srchbuilds="sersh pycsh"
  findPackage Moab MOAB "$BLDR_INSTALL_DIR" $srchbuilds
  findPycshDir Moab
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



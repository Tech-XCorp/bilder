#!/bin/sh
######################################################################
#
# @file    moab_aux.sh
#
# @brief   Trigger vars and find information for moab.
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

setMoabTriggerVars() {
  MOAB_REPO_URL=https://bitbucket.org/cadg4/moab.git
  MOAB_REPO_BRANCH_STD=stable-20170106
  MOAB_REPO_BRANCH_EXP=master
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_UPSTREAM_BRANCH_STD=master
  MOAB_UPSTREAM_BRANCH_EXP=master

# Using cmake? Eventually, need to get rid of autotools.
  if test -z "$MOAB_USE_CMAKE"; then
    if [[ `uname` =~ CYGWIN ]]; then
      MOAB_USE_CMAKE=true
    fi
  fi
  MOAB_USE_CMAKE=${MOAB_USE_CMAKE:-"true"}

# Determined Moab builds
  if test -z "$MOAB_BUILD_SET"; then
    MOAB_BUILD_SET=""
  fi
  local MOAB_ADD_PYBUILDS=false
  if test -z "$MOAB_DESIRED_BUILDS"; then
    MOAB_DESIRED_BUILDS=ser,par
    if ! [[ `uname` =~ CYGWIN ]]; then
      MOAB_DESIRED_BUILDS=${MOAB_DESIRED_BUILDS}
    fi
    MOAB_ADD_PYBUILDS=true
  fi

  local MOAB_DESIRED_BUILD_WITH_SET=""
  for i in $(echo $MOAB_DESIRED_BUILDS | sed "s/,/ /g")
  do
    # call your procedure/other scripts here below
    MOAB_DESIRED_BUILD_WITH_SET="${i}${MOAB_BUILD_SET},${MOAB_DESIRED_BUILD_WITH_SET}"
  done
  MOAB_DESIRED_BUILDS=${MOAB_DESIRED_BUILD_WITH_SET}

  computeBuilds moab
  if $MOAB_ADD_PYBUILDS; then
    addBuild moab sersh${MOAB_BUILD_SET} pycsh${MOAB_BUILD_SET}
    if [[ `uname` =~ CYGWIN ]]; then
      addBuild $* sermd${MOAB_BUILD_SET} pycst${MOAB_BUILD_SET}
    else
      addBuild $* ser${MOAB_BUILD_SET} pycst${MOAB_BUILD_SET}
    fi
  fi

# Determine moab deps
  MOAB_DEPS=netcdf,boost
  if echo "$MOAB_USE_CMAKE" | grep -q "true"; then
    MOAB_DEPS=$MOAB_DEPS,cmake
  else
    MOAB_DEPS=$MOAB_DEPS,autotools
    if test -z "$TRILINOSREPO_BUILD_SET"; then
      TRILINOS_BUILD_SET=commio
    fi
  fi
  if echo "$MOAB_BUILD_SET" | grep -q "Full"; then
# No need to specify $OCC as that is a dependency of cgm
    MOAB_DEPS=$MOAB_DEPS,cgm
  fi
  if echo "$MOAB_BUILDS" | grep -q "par"; then
    MOAB_DEPS=$MOAB_DEPS,trilinosrepo
  fi

}
setMoabTriggerVars

######################################################################
#
# Find moab
#
######################################################################

findMoab() {
  srchbuilds="ser${MOAB_BUILD_SET} pycst${MOAB_BUILD_SET} sersh${MOAB_BUILD_SET} pycsh${MOAB_BUILD_SET} par${MOAB_BUILD_SET}"
  findPackage Moab MOAB "$BLDR_INSTALL_DIR" $srchbuilds
  if echo "$MOAB_BUILDS" | grep -q "sersh"; then
    techo "Moab has sersh build, so finding pycsh dir."
    findPycshDir Moab
    if test -n "$MOAB_PYCSH_DIR"; then
      addtopathvar PATH ${MOAB_PYCSH_DIR}/bin
    fi
  fi
  if echo "$MOAB_BUILDS" | grep -q "ser"; then
    techo "Moab has ser build, so finding pycst dir."
    findPycstDir Moab
  fi
# Find cmake configuration directories
# This appends lib to the end of the CMAKE_BUILD_
  for bld in $srchbuilds; do
    local blddirvar=`genbashvar MOAB_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      techo "Defining variables for moab-${bld}."
      for subdir in lib; do
        if test -d $blddir/$subdir; then
          local dir=$blddir/$subdir
          if [[ `uname` =~ CYGWIN ]]; then
            dir=`cygpath -am $dir`
          fi
          local varname=`genbashvar MOAB_${bld}`_CMAKE_LIBDIR
          eval $varname=$dir
          printvar $varname
          varname=`genbashvar MOAB_${bld}`_CMAKE_LIBDIR_ARG
          eval $varname="\"-DMoab_ROOT_DIR:PATH='$dir'\""
          printvar $varname
          break
        fi
      done
    fi
  done
}


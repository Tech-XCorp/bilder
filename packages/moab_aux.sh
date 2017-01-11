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

# Determine Moab builds
  if test -z "$MOAB_BUILD_SET"; then
    MOAB_BUILD_SET=fullForPython
  fi
  if test -z "$MOAB_DESIRED_BUILDS"; then
# full depends on cgm, but not on trilinos.  Can be used for composers.
    if [[ $MOAB_BUILD_SET = full ]]; then
      MOAB_DESIRED_BUILDS=ser
    elif [[ $MOAB_BUILD_SET = fullForPython ]]; then
# full depends on cgm, but not on trilinos.  Uses the compiler that
# compiled python.
# Static serial and parallel builds needed for ulixes
      MOAB_DESIRED_BUILDS=ser,${FORPYTHON_STATIC_BUILD}
# Python shared build needed for composers
      if ! [[ `uname` =~ CYGWIN ]]; then
        MOAB_DESIRED_BUILDS=${MOAB_DESIRED_BUILDS},${FORPYTHON_SHARED_BUILD}
      fi
    elif [[ $MOAB_BUILD_SET = lite ]]; then
# Static serial and parallel builds needed for ulixes
      MOAB_DESIRED_BUILDS=serLite,parLite,
    elif [[ $MOAB_BUILD_SET = liteForPython ]]; then
# Static serial and parallel builds needed for ulixes
      MOAB_DESIRED_BUILDS=serLite,parLite,${FORPYTHON_STATIC_BUILD}Lite
# Python shared build needed for composers
# Python shared build needed for dagmc
      if ! [[ `uname` =~ CYGWIN ]]; then
        MOAB_DESIRED_BUILDS=${MOAB_DESIRED_BUILDS},${FORPYTHON_SHARED_BUILD}Lite
      fi
    else
      techo "moab_aux.sh: MOAB_BUILD_SET = ${MOAB_BUILD_SET} not one of full,fullForPython,lite,liteForPython"
      techo "moab_aux.sh: Setting MOAB_BUILD_SET = fullForPython"
      MOAB_BUILD_SET=fullForPython
# Static serial and parallel builds needed for ulixes
      MOAB_DESIRED_BUILDS=ser,par,${FORPYTHON_STATIC_BUILD}
# Python shared build needed for composers
      if ! [[ `uname` =~ CYGWIN ]]; then
        MOAB_DESIRED_BUILDS=${MOAB_DESIRED_BUILDS},${FORPYTHON_SHARED_BUILD}
      fi
    fi
  fi
  echo "Next, MOAB_DESIRED_BUILDS = $MOAB_DESIRED_BUILDS"
  computeBuilds moab

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
  if echo "$MOAB_BUILD_SET" | grep -q "full"; then
    MOAB_DEPS=$MOAB_DEPS,opencascade,cgm
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
  local moabBuildSet=""
  if [[ $MOAB_BUILD_SET = lite ]]; then
    moabBuildSet=Lite
  fi
  srchbuilds="ser${moabBuildSet} pycst${moabBuildSet} sersh${moabBuildSet} pycsh${moabBuildSet} par${moabBuildSet}"
  findPackage Moab MOAB "$BLDR_INSTALL_DIR" $srchbuilds
  techo
  findPycshDir Moab
  findPycstDir Moab
  if test -n "$MOAB_PYCSH_DIR"; then
    addtopathvar PATH ${MOAB_PYCSH_DIR}/bin
  fi
  techo "Done with finding packages"
# Find cmake configuration directories
# This appends lib to the end of the CMAKE_BUILD_
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
  techo "Done with defining variables"
}


#!/bin/bash
#
# Version and build information for moab
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

setMoabVersion() {
  # MOAB_BLDRVERSION=${MOAB_BLDRVERSION:-"4.7.0pre"}
  MOAB_REPO_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_REPO_TAG_STD=master
  MOAB_REPO_TAG_EXP=master
}
setMoabVersion

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setMoabGlobalVars() {
  MOAB_BUILD=$FORPYTHON_BUILD
  MOAB_BUILDS=${MOAB_BUILDS:-"$FORPYTHON_BUILD"}
  MOAB_DEPS=cgm
  MOAB_UMASK=002
}
setMoabGlobalVars

######################################################################
#
# Launch moab builds.
#
######################################################################

buildMoab() {

# Get moab from repo and remove any detritus
  updateRepo moab

# Determine whether to use cmake
  MOAB_USE_CMAKE=${MOAB_USE_CMAKE:-"true"}
  if $MOAB_USE_CMAKE; then
    MOAB_CMAKE_ARG=-c
  fi

# Preconfig or unpack
  if test -d $PROJECT_DIR/moab; then
    getVersion moab
    if ! bilderPreconfig $MOAB_CMAKE_ARG moab; then
      return 1
    fi
  else
    if ! bilderUnpack moab; then
      return 1
    fi
  fi

# Seek oce in one of many places
  local MOAB_OCE_DIR
  for i in volatile internal contrib; do
    if test -e /$i/oce; then
      MOAB_OCE_DIR=`(cd /$i/oce; pwd -P)`
      break
    fi
  done

# Set moab configure args
  if $MOAB_USE_CMAKE; then
    MOAB_ALL_ADDL_ARGS=
  else
    MOAB_ALL_ADDL_ARGS="--without-cubit"
    if test -n "$MOAB_OCE_DIR"; then
      MOAB_ALL_ADDL_ARGS="$MOAB_ALL_ADDL_ARGS --with-occ=$MOAB_OCE_DIR"
    fi
  fi

# Configure and build
  if bilderConfig $MOAB_CMAKE_ARG moab $MOAB_BUILD; then
    bilderBuild moab $MOAB_BUILD
  fi

}

######################################################################
#
# Test moab
#
######################################################################

testMoab() {
  techo "Not testing moab."
}

######################################################################
#
# Install moab
#
######################################################################

installMoab() {
  bilderInstallAll moab
}


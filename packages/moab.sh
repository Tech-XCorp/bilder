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

# Set other args, env
  local MOAB_ADDL_ARGS=
  local ocecmakedir=`findOceCmakeDir`
  if test -n "$ocecmakedir"; then
    techo -2 "ocecmakedir = $ocecmakedir."
    MOAB_ADDL_ARGS="$MOAB_ADDL_ARGS -DOCE_DIR:PATH=$ocecmakedir"
  fi

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$MOAB_MAKEJ_ARGS"
  fi

# Configure and build
  if bilderConfig $makerargs -c moab $MOAB_BUILD "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $MOAB_ADDL_ARGS $MOAB_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab $MOAB_BUILD "$makejargs" "$MOAB_ENV"
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


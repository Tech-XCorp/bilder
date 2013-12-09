#!/bin/bash
#
# Version and build information for coin
#
# See
# https://bitbucket.org/Coin3D/coin/wiki/Building%20from%20the%20command%20line
# to build coin on windows from the command line.
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Build from repo
# COIN_BLDRVERSION=${COIN_BLDRVERSION:-"3.1.3"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Only the python build needed.
COIN_BUILDS=${COIN_BUILDS:-"$FORPYTHON_BUILD"}
COIN_BUILD=$FORPYTHON_BUILD
COIN_DEPS=qt
COIN_UMASK=002
COIN_URL=https://bitbucket.org/Coin3D/coin
addtopathvar PATH $CONTRIB_DIR/coin/bin

######################################################################
#
# Launch coin builds.
#
######################################################################

#
# Get coin using hg.
#
getCoin() {
  techo "Updating coin from the repo."
  updateRepo coin
}

buildCoin() {

# Try to get coin from repo
  if ! (cd $PROJECT_DIR; getCoin); then
    echo "WARNING: Problem in getting coin."
  fi

# If no subdir, done.
  if ! test -d $PROJECT_DIR/coin; then
    techo "WARNING: Coin not found.  Not building."
    return 1
  fi

  if ! bilderUnpack Coin; then
    return
  fi

  local COIN_ADDL_ARGS=
  case `uname` in
    Darwin) COIN_ADDL_ARGS="$COIN_ADDL_ARGS --without-framework";;
  esac
  if bilderConfig Coin $FORPYTHON_BUILD "$CONFIG_COMPILERS_PYC CFLAGS='$PYC_CFLAGS -fpermissive' CXXFLAGS='$PYC_CXXFLAGS -fpermissive' $COIN_ADDL_ARGS $COIN_CC4PY_OTHER_ARGS"; then
      bilderBuild Coin $FORPYTHON_BUILD
  fi

}

######################################################################
#
# Test coin
#
######################################################################

testCoin() {
  techo "Not testing coin."
}

######################################################################
#
# Install coin
#
######################################################################

installCoin() {
  for bld in `echo $COIN_BUILDS | tr ',' ' '`; do
    bilderInstall -r Coin $bld
  done
}


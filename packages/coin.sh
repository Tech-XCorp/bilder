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
COIN_BLDRVERSION=${COIN_BLDRVERSION:-"3.1.3"}

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
COIN_UPSTREAM_URL=https://bitbucket.org/Coin3D/coin
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
    techo "WARNING: coin not found.  Not building."
    return 1
  fi

# Get version and preconfig
  getVersion coin
  if ! bilderPreconfig -p : coin; then
    return
  fi

  local COIN_ADDL_ARGS=
  local BASE_CC=`basename "$CC"`
  local BASE_CXX=`basename "$CXX"`
  local COIN_COMPILERS=
  case `uname` in
    CYGWIN*)
      COIN_ADDL_ARGS="$COIN_ADDL_ARGS --with-msvcrt=/md"
      COIN_COMPILERS="CC='' CXX=''"
      ;;
    Darwin)
      COIN_ADDL_ARGS="$COIN_ADDL_ARGS --without-framework"
      COIN_COMPILERS="CC='$BASE_CC' CXX='$BASE_CXX'"
      ;;
    *)
      COIN_COMPILERS="CC='$BASE_CC' CXX='$BASE_CXX'"
      ;;
  esac
  local COIN_CFLAGS="$PYC_CFLAGS"
  local COIN_CXXFLAGS="$PYC_CXXFLAGS"
  if [[ "$BASE_CC" =~ gcc ]]; then
    COIN_CFLAGS="$COIN_CFLAGS -fpermissive"
    COIN_CXXFLAGS="$COIN_CXXFLAGS -fpermissive"
  fi
  trimvar COIN_CFLAGS ' '
  trimvar COIN_CXXFLAGS ' '

  if bilderConfig coin $FORPYTHON_BUILD "CFLAGS='$COIN_CFLAGS' CXXFLAGS='$COIN_CXXFLAGS' $COIN_ADDL_ARGS $COIN_CC4PY_OTHER_ARGS" "" "$COIN_COMPILERS"; then
    bilderBuild -m make coin $FORPYTHON_BUILD "" "$COIN_COMPILERS"
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
    bilderInstall -m make -r coin $bld
  done
}


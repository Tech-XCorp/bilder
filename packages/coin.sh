#!/bin/bash
#
# Version and build information for coin
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

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
addtopathvar PATH $CONTRIB_DIR/coin/bin

######################################################################
#
# Launch coin builds.
#
######################################################################

buildCoin() {

  if bilderUnpack Coin; then
    local COIN_ADDL_ARGS=
    case `uname` in
      Darwin)
        COIN_ADDL_ARGS="$COIN_ADDL_ARGS --without-framework"
        ;;
    esac
    if bilderConfig Coin sersh "$CONFIG_COMPILERS_SER CFLAGS='$CFLAGS -fpermissive' CXXFLAGS='$CXXFLAGS -fpermissive' $COIN_ADDL_ARGS $COIN_SERSH_OTHER_ARGS"; then
      bilderBuild Coin sersh
    fi
    if bilderConfig Coin cc4py "$CONFIG_COMPILERS_PYC CFLAGS='$PYC_CFLAGS -fpermissive' CXXFLAGS='$PYC_CXXFLAGS -fpermissive' $COIN_ADDL_ARGS $COIN_CC4PY_OTHER_ARGS"; then
      bilderBuild Coin cc4py
    fi
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


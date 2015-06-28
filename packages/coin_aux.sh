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

setCoinTriggerVars() {

  COIN_USE_REPO=${COIN_USE_REPO:-"false"}
  if $COIN_USE_REPO; then
    # COIN_REPO_URL=https://bitbucket.org/Coin3D/coin # original
    COIN_REPO_URL=https://bitbucket.org/cbuehler/coin # cmake fork
    COIN_CMAKE_ARGS=-c
    COIN_NAME=coin
    COIN_REPO_BRANCH_STD=default
    COIN_REPO_BRANCH_EXP=default
    COIN_UPSTREAM_URL=https://bitbucket.org/Coin3D/coin
    COIN_UPSTREAM_BRANCH_STD=default
    COIN_UPSTREAM_BRANCH_EXP=default
  else
    COIN_BLDRVERSION_STD=${COIN_BLDRVERSION_STD:-"3.1.3"}
    COIN_BLDRVERSION_EXP=${COIN_BLDRVERSION_EXP:-"3.1.3"}
    COIN_NAME=Coin
  fi
  COIN_BUILDS=${FORPYTHON_SHARED_BUILD}
  COIN_DEPS=qt
  if $COIN_USE_REPO; then
    COIN_DEPS=$COIN_DEPS,cmake
  fi

}
setCoinTriggerVars

######################################################################
#
# Find coin
#
######################################################################

findCoin() {
  :
}


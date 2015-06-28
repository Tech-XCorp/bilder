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

  COIN_USE_GIT=${COIN_USE_GIT:-"false"}
  if $COIN_USE_GIT; then
# CMake fork: https://bitbucket.org/cbuehler/coin
    COIN_REPO_URL=https://bitbucket.org/Coin3D/coin
    COIN_REPO_BRANCH_STD=master
    COIN_REPO_BRANCH_EXP=master
    COIN_UPSTREAM_URL=https://bitbucket.org/Coin3D/coin
    COIN_UPSTREAM_BRANCH_STD=master
    COIN_UPSTREAM_BRANCH_EXP=master
  else
    COIN_BLDRVERSION_STD=${COIN_BLDRVERSION_STD:-"3.1.3"}
    COIN_BLDRVERSION_EXP=${COIN_BLDRVERSION_EXP:-"3.1.3"}
  fi

  if test -z "$COIN_BUILDS"; then
    COIN_BUILDS=par
    case `uname` in
      CYGWIN*) ;;
      Darwin) COIN_BUILDS="${COIN_BUILDS},parsh";;
      Linux) COIN_BUILDS="${COIN_BUILDS},parsh";;
    esac
  fi
  COIN_DEPS=qt

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


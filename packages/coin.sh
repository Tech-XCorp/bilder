#!/bin/bash
#
# Build information for coin
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in coin_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/coin_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setFreetypeNonTriggerVars() {
  COIN_UMASK=002
}
setFreetypeNonTriggerVars

######################################################################
#
# Launch coin builds.
#
######################################################################

buildCoin() {

# Get or preconfig git
  local res=0
  if $COIN_USE_GIT; then
    updateRepo coin
    getVersion coin
# Always install in contrib dir for consistency
    bilderPreconfig -I $CONTRIB_DIR coin
    res=$?
  else
    bilderUnpack coin
    res=$?
  fi
  if test $res != 0; then
    return
  fi

  COMPILERS_COIN="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC "
  local otherargsvar=`genbashvar COIN_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig $COIN_CMAKE_ARGS $COIN_NAME $FORPYTHON_SHARED_BUILD "$COMPILERS_COIN $COIN_ADDL_ARGS $otherargs" "" "$COIN_ENV"; then
    bilderBuild $COIN_MAKER_ARGS $COIN_NAME $FORPYTHON_SHARED_BUILD "" "$COIN_ENV"
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
    bilderInstall $COIN_MAKER_ARGS -r $COIN_NAME $bld
  done
}


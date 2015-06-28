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
  if $COIN_USE_REPO; then
    updateRepo coin
    getVersion coin
# Always install in contrib dir for consistency
    bilderPreconfig -p : -I $CONTRIB_DIR coin
    res=$?
  else
    bilderUnpack coin
    res=$?
  fi
  if test $res != 0; then
    return
  fi

# Get build args
  local COIN_ADDL_ARGS=
  local BASE_CC=`basename "$CC"`
  local BASE_CXX=`basename "$CXX"`
  local COMPILERS_COIN=
  local COIN_CFLAGS=
  local COIN_CXXFLAGS=
  local COIN_MAKER_ARGS=
  local COIN_ENV=
  if test -z "$COIN_CMAKE_ARGS"; then
    case `uname` in
      CYGWIN*)
# Not clear that coin build msvc anymore, looking at recent commits, for
# base repo.
        COIN_ADDL_ARGS="$COIN_ADDL_ARGS --with-msvcrt=/md"
        COIN_DBG_ADDL_ARGS="$COIN_DBG_ADDL_ARGS --with-msvcrt=/mdd"
        COIN_MAKER_ARGS="-m make"
        COIN_ENV="CC='' CXX=''"
        ;;
      Darwin)
        COIN_ADDL_ARGS="$COIN_ADDL_ARGS --without-framework"
        COIN_ENV="CC='$BASE_CC' CXX='$BASE_CXX'"
        ;;
      *)
        COIN_ENV="CC='$BASE_CC' CXX='$BASE_CXX'"
        ;;
    esac
    COIN_CFLAGS="$PYC_CFLAGS"
    COIN_CXXFLAGS="$PYC_CXXFLAGS"
    if [[ "$BASE_CC" =~ gcc ]]; then
      COIN_CFLAGS="$COIN_CFLAGS -fpermissive"
      COIN_CXXFLAGS="$COIN_CXXFLAGS -fpermissive"
    fi
    trimvar COIN_CFLAGS ' '
    trimvar COIN_CXXFLAGS ' '
    COIN_ENV="$COIN_ENV CFLAGS='$COIN_CFLAGS' CXXFLAGS='$COIN_CXXFLAGS'"
  else
    COMPILERS_COIN="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
  fi

# Build
  eval COIN_${FORPYTHON_SHARED_BUILD}_INSTALL_DIR=$CONTRIB_DIR
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


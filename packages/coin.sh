#!/bin/bash
#
# Version and build information for coin
#
# $Id: coin.sh 6131 2012-05-27 17:16:54Z cary $
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
# Other values
#
######################################################################

if test -z "$COIN_BUILDS"; then
  COIN_BUILDS="cc4py"
fi
COIN_DEPS=qt

######################################################################
#
# Add to path, as needed by soqt.
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/coin/bin

######################################################################
#
# Launch coin builds.
#
######################################################################

buildCoin() {

  if bilderUnpack Coin; then
    local COIN_CC4PY_ADDL_ARGS=
    case `uname` in
      Darwin)
        # COIN_CC4PY_ADDL_ARGS="$COIN_CC4PY_ADDL_ARGS --with-framework-prefix=$CONTRIB_DIR/Coin-${COIN_BLDRVERSION}-cc4py"
        COIN_CC4PY_ADDL_ARGS="$COIN_CC4PY_ADDL_ARGS --without-framework"
        ;;
    esac
    if bilderConfig Coin cc4py "$COIN_CC4PY_ADDL_ARGS $COIN_CC4PY_OTHER_ARGS"; then
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
  if bilderInstall -r Coin cc4py; then
    :
  fi
  # techo "WARNING: Quitting at end of coin.sh."; cleanup
}


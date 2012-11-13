#!/bin/bash
#
# Version and build information for soqt
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SOQT_BLDRVERSION=${SOQT_BLDRVERSION:-"1.5.0"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$SOQT_BUILDS"; then
  SOQT_BUILDS="cc4py"
fi
SOQT_DEPS=Coin,qt

######################################################################
#
# Add to path
#
######################################################################

# addtopathvar PATH $CONTRIB_DIR/soqt/bin

######################################################################
#
# Launch soqt builds.
#
######################################################################

buildSoQt() {

  case `uname` in
    CYGWIN) ;;
    *) SOQT_CC4PY_ENV="QTDIR=$CONTRIB_DIR/qt-$QT_BLDRVERSION-ser";;
  esac

  if bilderUnpack SoQt; then
    if bilderConfig -p Coin-$COIN_BLDRVERSION-cc4py SoQt cc4py "$SOQT_CC4PY_ADDL_ARGS $SOQT_CC4PY_OTHER_ARGS" "" "$SOQT_CC4PY_ENV"; then
      bilderBuild SoQt cc4py
    fi
  fi

}

######################################################################
#
# Test soqt
#
######################################################################

testSoQt() {
  techo "Not testing SoQt."
}

######################################################################
#
# Install soqt
#
######################################################################

installSoQt() {
  if bilderInstall -L SoQt cc4py; then
    :
  fi
  # techo "WARNING: Quitting at end of soqt.sh."; cleanup
}


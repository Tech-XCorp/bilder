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
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# SOQT_DESIRED_BUILDS=${SOQT_DESIRED_BUILDS:-"sersh"}
computeBuilds soqt
addCc4pyBuild soqt
SOQT_DEPS=Coin,qt
# addtopathvar PATH $CONTRIB_DIR/soqt/bin

######################################################################
#
# Launch soqt builds.
#
######################################################################

buildSoQt() {

  case `uname` in
    CYGWIN) ;;
    *) SOQT_CC4PY_ENV="QTDIR=$CONTRIB_DIR/qt-$QT_BLDRVERSION-sersh";;
  esac

  if bilderUnpack SoQt; then
    if bilderConfig -p Coin-$COIN_BLDRVERSION-$FORPYTHON_BUILD SoQt cc4py "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $SOQT_CC4PY_OTHER_ARGS" "" "$SOQT_CC4PY_ENV"; then
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


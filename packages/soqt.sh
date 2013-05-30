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

# SoQt is installed with Coin, so it is built the way Coin is built
SOQT_BUILDS=${SOQT_BUILDS:-"$FORPYTHON_BUILD"}
SOQT_DEPS=Coin,qt
SOQT_UMASK=002
# addtopathvar PATH $CONTRIB_DIR/soqt/bin

######################################################################
#
# Launch soqt builds.
#
######################################################################

buildSoQt() {

  case `uname` in
    CYGWIN) ;;
    *)
      SOQT_SERSH_ENV="QTDIR=$CONTRIB_DIR/qt-$QT_BLDRVERSION-sersh"
      SOQT_CC4PY_ENV="QTDIR=$CONTRIB_DIR/qt-$QT_BLDRVERSION-cc4py"
      ;;
  esac

  if bilderUnpack SoQt; then
    if bilderConfig -p Coin-$COIN_BLDRVERSION-sersh SoQt $FORPYTHON_BUILD "$CONFIG_COMPILERS_SERSH CFLAGS='$CFLAGS -fpermissive' CXXFLAGS='$CXXFLAGS -fpermissive' $SOQT_SERSH_OTHER_ARGS" "" "$SOQT_SERSH_ENV"; then
      bilderBuild SoQt sersh
    fi
    if bilderConfig -p Coin-$COIN_BLDRVERSION-cc4py SoQt $FORPYTHON_BUILD "$CONFIG_COMPILERS_PYC CFLAGS='$PYC_CFLAGS -fpermissive' CXXFLAGS='$PYC_CXXFLAGS -fpermissive' $SOQT_CC4PY_OTHER_ARGS" "" "$SOQT_CC4PY_ENV"; then
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
  for bld in `echo $SOQT_BUILDS | tr ',' ' '`; do
    bilderInstall -L SoQt $bld
  done
}


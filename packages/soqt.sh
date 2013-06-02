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
SOQT_BUILD=${SOQT_BUILD:-"$FORPYTHON_BUILD"}
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
      SOQT_ENV="QTDIR=$CONTRIB_DIR/qt-$QT_BLDRVERSION-$SOQT_BUILD"
      ;;
  esac

  if bilderUnpack SoQt; then
    local otherargsvar=`genbashvar SOQT_${SOQT_BUILD}`_OTHER_ARGS
    local otherargsval=`deref ${otherargsvar}`
    if bilderConfig -p Coin-$COIN_BLDRVERSION-$SOQT_BUILD SoQt $SOQT_BUILD "$CONFIG_COMPILERS_PYC CFLAGS='$CFLAGS -fpermissive' CXXFLAGS='$CXXFLAGS -fpermissive' $otherargsval" "" "$SOQT_ENV"; then
      bilderBuild SoQt $SOQT_BUILD
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


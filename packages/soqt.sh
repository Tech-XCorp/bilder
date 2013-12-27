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
SOQT_DEPS=coin,qt
SOQT_UMASK=002
SOQT_URL=https://bitbucket.org/Coin3D/soqt
SOQT_UPSTREAM_URL=https://bitbucket.org/Coin3D/soqt

######################################################################
#
# Launch soqt builds.
#
######################################################################

#
# Get coin using hg.
#
getSoQt() {
  techo "Updating soqt from the repo."
  updateRepo soqt
}

buildSoQt() {

# Try to get soqt from repo
  if ! (cd $PROJECT_DIR; getSoQt); then
    echo "WARNING: Problem in getting soqt."
  fi

# If no subdir, done.
  if ! test -d $PROJECT_DIR/soqt; then
    techo "WARNING: soqt not found.  Not building."
    return 1
  fi

# Get version and preconfig
  getVersion soqt
  if ! bilderPreconfig -p : soqt; then
    return
  fi

# Get configure args
  local SOQT_ADDL_ARGS=
  local BASE_CC=`basename "$CC"`
  local BASE_CXX=`basename "$CXX"`
  local SOQT_COMPILERS=
  case `uname` in
    CYGWIN*)
      SOQT_ADDL_ARGS="$SOQT_ADDL_ARGS --with-msvcrt=/md"
      SOQT_COMPILERS="CC='' CXX=''"
      ;;
    Darwin)
      SOQT_ADDL_ARGS="$SOQT_ADDL_ARGS --without-framework"
      SOQT_COMPILERS="CC='$BASE_CC' CXX='$BASE_CXX'"
      ;;
    *)
      SOQT_COMPILERS="CC='$BASE_CC' CXX='$BASE_CXX'"
      ;;
  esac
  local SOQT_CFLAGS="$PYC_CFLAGS"
  local SOQT_CXXFLAGS="$PYC_CXXFLAGS"
  if [[ "$BASE_CC" =~ gcc ]]; then
    SOQT_CFLAGS="$SOQT_CFLAGS -fpermissive"
    SOQT_CXXFLAGS="$SOQT_CXXFLAGS -fpermissive"
  fi
  trimvar SOQT_CFLAGS ' '
  trimvar SOQT_CXXFLAGS ' '
  local otherargsvar=`genbashvar SOQT_${SOQT_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`

# Set env
  case `uname` in
    CYGWIN*) ;;
    *)
      SOQT_ENV="QTDIR=$CONTRIB_DIR/qt-$QT_BLDRVERSION-$SOQT_BUILD"
      if test -d $BLDR_INSTALL_DIR/coin-sersh/bin; then
        local COIN_BINDIR=`(cd $BLDR_INSTALL_DIR/coin-sersh/bin; pwd -P)`
        SOQT_ENV="$SOQT_ENV PATH=$COIN_BINDIR:'$PATH'"
      fi
      ;;
  esac
  SOQT_ENV="$SOQT_ENV $SOQT_COMPILERS"

# Configure and build
  if bilderConfig -p coin-$COIN_BLDRVERSION-$SOQT_BUILD soqt $SOQT_BUILD "CFLAGS='$SOQT_CFLAGS' CXXFLAGS='$SOQT_CXXFLAGS' $otherargsval" "" "$SOQT_ENV"; then
    bilderBuild -m make soqt $SOQT_BUILD "" "$SOQT_ENV"
  fi

}

######################################################################
#
# Test soqt
#
######################################################################

testSoQt() {
  techo "Not testing soqt."
}

######################################################################
#
# Install soqt
#
######################################################################

installSoQt() {
  for bld in `echo $SOQT_BUILDS | tr ',' ' '`; do
    bilderInstall -m make -L soqt $bld
  done
}


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
if $COIN_USE_REPO; then
  SOQT_NAME=soqt
else
  SOQT_NAME=SoQt
fi

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# SoQt is installed with Coin, so it is built the way Coin is built.
if test -z "$SOQT_BUILDS"; then
  SOQT_BUILDS=${FORPYTHON_BUILD}
  if [[ `uname` =~ CYGWIN ]]; then
    SOQT_BUILDS=${SOQT_BUILDS},${FORPYTHON_BUILD}dbg
  fi
fi
SOQT_DEPS=coin,qt
SOQT_UMASK=002
SOQT_REPO_URL=https://bitbucket.org/Coin3D/soqt
SOQT_UPSTREAM_URL=https://bitbucket.org/Coin3D/soqt

######################################################################
#
# Launch soqt builds.
#
######################################################################

#
# Get soqt using hg.
#
getSoQt() {
  techo "Updating soqt from the repo."
  updateRepo soqt
}

buildSoQt() {

  if $COIN_USE_REPO; then

# Try to get soqt from repo
    if ! (cd $PROJECT_DIR; getSoQt); then
      echo "WARNING: Problem in getting soqt."
    fi

# If no subdir, done.
    if ! test -d $PROJECT_DIR/soqt; then
      techo "WARNING: soqt not found.  Not building."
      return 1
    fi

# Get version, patch, and preconfig
    getVersion soqt
# Patch if present
    local patchfile=$BILDER_DIR/patches/soqt.patch
    if test -e $patchfile; then
      SOQT_PATCH="$patchfile"
      cmd="(cd $PROJECT_DIR/soqt; patch -p1 <$patchfile)"
      techo "$cmd"
      eval "$cmd"
    fi
    # rm -f $PROJECT_DIR/soqt/*-soqt-preconfig.txt
    if ! bilderPreconfig -p : soqt; then
      return
    fi

  else

# Build from tarball
    if ! bilderUnpack SoQt; then
      return 1
    fi

  fi

# Get configure args
  local SOQT_ADDL_ARGS=
  local BASE_CC=`basename "$CC"`
  local BASE_CXX=`basename "$CXX"`
  local SOQT_COMPILERS=
  case `uname` in
    CYGWIN*)
      SOQT_ADDL_ARGS="$SOQT_ADDL_ARGS --with-msvcrt=/md"
      SOQT_DBG_ADDL_ARGS="$SOQT_DBG_ADDL_ARGS --with-msvcrt=/mdd"
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
  local otherargsvar=`genbashvar SOQT_${FORPYTHON_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`

# Set env
  local SOQT_QTDIR=$QT_CC4PY_DIR
  SOQT_QTDIR=${SOQT_QTDIR:-"$QT_SERSH_DIR"}
  if test -z "$SOQT_DIR" -a -n "$QT_SER_DIR"; then
    techo "WARNING: Qt is installed in ser dir, not sersh dir.  Reinstallation needed."
    SOQT_QTDIR="$QT_SER_DIR"
  fi
  if test -z "$SOQT_QTDIR"; then
    techo "WARNING: Qt not found."
  fi
  local SOQT_ENV=
  local SOQT_DBG_ENV=
  if test -n "$SOQT_QTDIR"; then
    SOQT_ENV="QTDIR=$SOQT_QTDIR"
    SOQT_DBG_ENV="QTDIR=$SOQT_QTDIR"
  fi
  local COIN_DIR=
  if $COIN_USE_REPO; then
    if test -d $BLDR_INSTALL_DIR/${COIN_NAME}-${FORPYTHON_BUILD}/bin; then
      COIN_DIR=`(cd $BLDR_INSTALL_DIR/${COIN_NAME}-${FORPYTHON_BUILD}; pwd -P)`
    fi
  else
    if test -d $CONTRIB_DIR/${COIN_NAME}-${FORPYTHON_BUILD}/bin; then
      COIN_DIR=`(cd $CONTRIB_DIR/${COIN_NAME}-${FORPYTHON_BUILD}; pwd -P)`
    fi
  fi
  if text -n "$COIN_DIR"; then
    local COIN_BINDIR=$COIN_DIR/bin
    SOQT_ENV="$SOQT_ENV PATH=$COIN_BINDIR:'$PATH'"
    if [[ `uname` =~ CYGWIN ]]; then
      local COIN_DBG_BINDIR=${COIN_DIR}dbg/bin
      SOQT_DBG_ENV="$SOQT_DBG_ENV PATH=$COIN_DBG_BINDIR:'$PATH'"
    fi
  fi
  SOQT_ENV="$SOQT_ENV $SOQT_COMPILERS"
  trimvar SOQT_ENV ' '
  SOQT_DBG_ENV="$SOQT_DBG_ENV $SOQT_COMPILERS"
  trimvar SOQT_DBG_ENV ' '

# Configure and build
  if bilderConfig -p $COIN_NAME-$COIN_BLDRVERSION-$FORPYTHON_BUILD $SOQT_NAME $FORPYTHON_BUILD "CFLAGS='$SOQT_CFLAGS' CXXFLAGS='$SOQT_CXXFLAGS' $SOQT_ADDL_ARGS $otherargsval" "" "$SOQT_ENV"; then
    bilderBuild -m make $SOQT_NAME $FORPYTHON_BUILD "" "$SOQT_ENV"
  fi
  if bilderConfig -p $COIN_NAME-$COIN_BLDRVERSION-${FORPYTHON_BUILD}dbg $SOQT_NAME ${FORPYTHON_BUILD}dbg "CFLAGS='$SOQT_CFLAGS' CXXFLAGS='$SOQT_CXXFLAGS' $SOQT_DBG_ADDL_ARGS $otherargsval" "" "$SOQT_DBG_ENV"; then
    bilderBuild -m make $SOQT_NAME ${FORPYTHON_BUILD}dbg "" "$SOQT_DBG_ENV"
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
    bilderInstall -m make -L $SOQT_NAME $bld
  done
}


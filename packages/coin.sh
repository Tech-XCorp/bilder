#!/bin/bash
#
# Version and build information for coin.
#
# Tarballs: https://bitbucket.org/Coin3D/coin/downloads
# Trunk: https://bitbucket.org/Coin3D/coin
# CMake fork: https://bitbucket.org/cbuehler/coin
#
# See
# https://bitbucket.org/Coin3D/coin/wiki/Building%20from%20the%20command%20line
# to build coin on windows from the command line.
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Build from tarball
COIN_BLDRVERSION=${COIN_BLDRVERSION:-"3.1.3"}
COIN_USE_REPO=false
if $COIN_USE_REPO; then
  COIN_NAME=coin
else
  COIN_NAME=Coin
fi

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setCoinGlobalVars() {
# Only python builds needed.
  if test -z "$COIN_BUILDS"; then
    COIN_BUILDS=${FORPYTHON_SHARED_BUILD}
    if [[ `uname` =~ CYGWIN ]]; then
      COIN_BUILDS=${COIN_BUILDS},${FORPYTHON_SHARED_BUILD}dbg
    fi
  fi
  COIN_DEPS=qt
  COIN_UMASK=002
  COIN_REPO_URL=https://bitbucket.org/Coin3D/coin
  COIN_UPSTREAM_URL=https://bitbucket.org/Coin3D/coin
  # COIN_REPO_URL=https://bitbucket.org/cbuehler/coin
  # COIN_UPSTREAM_URL=https://bitbucket.org/cbuehler/coin
  # COIN_CMAKE_ARG=-c # Goes with above repo only.
# Needed to configure soqt
  if $COIN_USE_REPO; then
    addtopathvar PATH $BLDR_INSTALL_DIR/coin-${FORPYTHON_SHARED_BUILD}/bin
  else
    addtopathvar PATH $CONTRIB_DIR/Coin-${FORPYTHON_SHARED_BUILD}/bin
  fi
}
setCoinGlobalVars

######################################################################
#
# Launch coin builds.
#
######################################################################

#
# Get coin using hg.
#
getCoin() {
  techo "Updating coin from the repo."
  updateRepo coin
}

buildCoin() {

  if $COIN_USE_REPO; then

# Remove other coin
    rm -rf $CONTRIB_DIR/{Coin,SoQt}-*
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR Coin,${FORPYTHON_SHARED_BUILD}
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR SoQt,${FORPYTHON_SHARED_BUILD}

# Try to get coin from repo
    if ! (cd $PROJECT_DIR; getCoin); then
      echo "WARNING: Problem in getting coin."
    fi

# If no subdir, done.
    if ! test -d $PROJECT_DIR/coin; then
      techo "WARNING: coin not found.  Not building."
      return 1
    fi

# Get version and preconfig
    getVersion coin
# Patch if present
    local patchfile=$BILDER_DIR/patches/coin.patch
    if test -e $patchfile; then
      COIN_PATCH="$patchfile"
      cmd="(cd $PROJECT_DIR/coin; patch -p1 <$patchfile)"
      techo "$cmd"
      eval "$cmd"
    fi
# If not using cmake, do not preconfig
    COIN_PRECONFIG_ARGS=${COIN_CMAKE_ARGS:-"-p :"}
    if ! bilderPreconfig $COIN_PRECONFIG_ARGS coin; then
      return 1
    fi

  else

# Remove other coin, soqt
    rm -rf $BLDR_INSTALL_DIR/{coin,soqt}-*
    $BILDER_DIR/setinstald.sh -r -i $BLDR_INSTALL_DIR coin,${FORPYTHON_SHARED_BUILD}
    $BILDER_DIR/setinstald.sh -r -i $BLDR_INSTALL_DIR soqt,${FORPYTHON_SHARED_BUILD}

# Build from tarball
    if ! bilderUnpack Coin; then
      return 1
    fi

  fi

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
    COMPILERS_COIN="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC "
  fi

  local otherargsvar=`genbashvar COIN_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig $COIN_CMAKE_ARGS $COIN_NAME $FORPYTHON_SHARED_BUILD "$COMPILERS_COIN $COIN_ADDL_ARGS $otherargs" "" "$COIN_ENV"; then
    bilderBuild $COIN_MAKER_ARGS $COIN_NAME $FORPYTHON_SHARED_BUILD "" "$COIN_ENV"
  fi

if false; then
  if bilderConfig $COIN_NAME ${FORPYTHON_SHARED_BUILD}dbg "CFLAGS='$COIN_CFLAGS' CXXFLAGS='$COIN_CXXFLAGS' $COIN_DBG_ADDL_ARGS $COIN_PYCSH_OTHER_ARGS" "" "$COIN_ENV"; then
    bilderBuild -m make $COIN_NAME ${FORPYTHON_SHARED_BUILD}dbg "" "$COIN_ENV"
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
  for bld in `echo $COIN_BUILDS | tr ',' ' '`; do
    bilderInstall $COIN_MAKER_ARGS -r $COIN_NAME $bld
  done
}


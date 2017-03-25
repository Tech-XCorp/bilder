#!/bin/sh
######################################################################
#
# @file    pivy.sh
#
# @brief   Version and build information for pivy.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PIVY_BLDRVERSION=${PIVY_BLDRVERSION:-"1.5.0"}
if $COIN_USE_REPO; then
  PIVY_NAME=pivy
else
  PIVY_NAME=Pivy
fi

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Pivy is installed with Coin, so it is built the way Coin is built
PIVY_BUILDS=${PIVY_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
PIVY_BUILD=${PIVY_BUILD:-"$FORPYTHON_SHARED_BUILD"}
PIVY_DEPS=coin
PIVY_UMASK=002
PIVY_REPO_URL=https://bitbucket.org/Coin3D/pivy
PIVY_UPSTREAM_URL=https://bitbucket.org/Coin3D/pivy

######################################################################
#
# Launch pivy builds.
#
######################################################################

#
# Get pivy using hg.
#
getPivy() {
  techo "Updating pivy from the repo."
  updateRepo pivy
}

buildPivy() {

  if $COIN_USE_REPO; then

# Try to get pivy from repo
    if ! (cd $PROJECT_DIR; getPivy); then
      echo "WARNING: Problem in getting pivy."
    fi

# If no subdir, done.
    if ! test -d $PROJECT_DIR/pivy; then
      techo "WARNING: pivy not found.  Not building."
      return 1
    fi

# Get version, patch, and preconfig
    getVersion pivy
# Patch if present
    local patchfile=$BILDER_DIR/patches/pivy.patch
    if test -e $patchfile; then
      PIVY_PATCH="$patchfile"
      cmd="(cd $PROJECT_DIR/pivy; patch -p1 <$patchfile)"
      techo "$cmd"
      eval "$cmd"
    fi
    # rm -f $PROJECT_DIR/pivy/*-pivy-preconfig.txt
    if ! bilderPreconfig -p : pivy; then
      return
    fi

  else

# Build from tarball
    if ! bilderUnpack Pivy; then
      return 1
    fi

  fi

# Get configure args
  local PIVY_ADDL_ARGS=
  local BASE_CC=`basename "$CC"`
  local BASE_CXX=`basename "$CXX"`
  local PIVY_COMPILERS=
  case `uname` in
    CYGWIN*)
      PIVY_ADDL_ARGS="$PIVY_ADDL_ARGS --with-msvcrt=/md"
      PIVY_COMPILERS="CC='' CXX=''"
      ;;
    Darwin)
      PIVY_ADDL_ARGS="$PIVY_ADDL_ARGS --without-framework"
      PIVY_COMPILERS="CC='$BASE_CC' CXX='$BASE_CXX'"
      ;;
    *)
      PIVY_COMPILERS="CC='$BASE_CC' CXX='$BASE_CXX'"
      ;;
  esac
  local PIVY_CFLAGS="$PYC_CFLAGS"
  local PIVY_CXXFLAGS="$PYC_CXXFLAGS"
  if [[ "$BASE_CC" =~ gcc ]]; then
    PIVY_CFLAGS="$PIVY_CFLAGS -fpermissive"
    PIVY_CXXFLAGS="$PIVY_CXXFLAGS -fpermissive"
  fi
  trimvar PIVY_CFLAGS ' '
  trimvar PIVY_CXXFLAGS ' '
  local otherargsvar=`genbashvar PIVY_${PIVY_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`

# Set env
  local PIVY_QTDIR=$QT_PYCSH_DIR
  PIVY_QTDIR=${PIVY_QTDIR:-"$QT_SERSH_DIR"}
  local PIVY_ENV="QTDIR=$PIVY_QTDIR"
  case `uname` in
    CYGWIN*) ;;
    *)
      if test -d $BLDR_INSTALL_DIR/${COIN_NAME}-sersh/bin; then
        local COIN_BINDIR=`(cd $BLDR_INSTALL_DIR/${COIN_NAME}-sersh/bin; pwd -P)`
        PIVY_ENV="$PIVY_ENV PATH=$COIN_BINDIR:'$PATH'"
      fi
      ;;
  esac
  PIVY_ENV="$PIVY_ENV $PIVY_COMPILERS"
  trimvar PIVY_ENV ' '

# Configure and build
  # if bilderConfig -p $COIN_NAME-$COIN_BLDRVERSION-pycsh $PIVY_NAME pycsh "CFLAGS='$PIVY_CFLAGS' CXXFLAGS='$PIVY_CXXFLAGS' $PIVY_ADDL_ARGS $otherargsval" "" "$PIVY_ENV"; then
  bilderDuBuild $PIVY_NAME pycsh "" "$PIVY_ENV"

}

######################################################################
#
# Test pivy
#
######################################################################

testPivy() {
  techo "Not testing pivy."
}

######################################################################
#
# Install pivy
#
######################################################################

installPivy() {
  for bld in `echo pycshS | tr ',' ' '`; do
    bilderInstall -m make -L $PIVY_NAME $bld
  done
}


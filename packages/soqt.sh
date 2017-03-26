#!/bin/sh
######################################################################
#
# @file    soqt.sh
#
# @brief   Version and build information for soqt.
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

SOQT_BLDRVERSION=${SOQT_BLDRVERSION:-"1.5.0"}
# Repo and tarball have different capitalization
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

setSoQtGlobalVars() {
# SoQt is installed with Coin, so it is built the way Coin is built.
  if test -z "$SOQT_BUILDS"; then
    SOQT_BUILDS=${FORPYTHON_SHARED_BUILD}
    if [[ `uname` =~ CYGWIN ]]; then
      SOQT_BUILDS=${SOQT_BUILDS},${FORPYTHON_SHARED_BUILD}dbg
    fi
  fi
  SOQT_DEPS=coin
  SOQT_UMASK=002
  SOQT_REPO_URL=https://bitbucket.org/Coin3D/soqt
  SOQT_UPSTREAM_URL=https://bitbucket.org/Coin3D/soqt
  # SOQT_CMAKE_ARG=-c # Someday?
}
setSoQtGlobalVars

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
# If not using cmake, do not preconfig
    SOQT_PRECONFIG_ARGS=${SOQT_CMAKE_ARGS:-"-p :"}
    if ! bilderPreconfig $SOQT_PRECONFIG_ARGS soqt; then
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
  local COMPILERS_SOQT=
  local SOQT_CFLAGS=
  local SOQT_CXXFLAGS=
  local SOQT_MAKER_ARGS=
  local SOQT_ENV=
  if test -z "$COIN_CMAKE_ARGS"; then
    case `uname` in
      CYGWIN*)
        SOQT_ADDL_ARGS="$SOQT_ADDL_ARGS --with-msvcrt=/md"
        SOQT_DBG_ADDL_ARGS="$SOQT_DBG_ADDL_ARGS --with-msvcrt=/mdd"
        SOQT_ENV="CC='' CXX=''"
        SOQT_MAKER_ARGS="-m make"
        ;;
      Darwin)
        SOQT_ADDL_ARGS="$SOQT_ADDL_ARGS --without-framework"
        SOQT_ENV="CC='$BASE_CC' CXX='$BASE_CXX'"
        ;;
      *)
        SOQT_ENV="CC='$BASE_CC' CXX='$BASE_CXX'"
        ;;
    esac
    SOQT_CFLAGS="$PYC_CFLAGS"
    SOQT_CXXFLAGS="$PYC_CXXFLAGS"
    if [[ "$BASE_CC" =~ gcc ]]; then
      SOQT_CFLAGS="$SOQT_CFLAGS -fpermissive"
      SOQT_CXXFLAGS="$SOQT_CXXFLAGS -fpermissive"
    fi
    trimvar SOQT_CFLAGS ' '
    trimvar SOQT_CXXFLAGS ' '
  else
    COMPILERS_SOQT="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC "
  fi

# Find qt
  local SOQT_QTDIR=$QT_PYCSH_DIR
  SOQT_QTDIR=${SOQT_QTDIR:-"$QT_SERSH_DIR"}
  if test -z "$SOQT_DIR" -a -n "$QT_SER_DIR"; then
    techo "WARNING: Qt is installed in ser dir, not sersh dir.  Reinstallation needed."
    SOQT_QTDIR="$QT_SER_DIR"
  fi
  if test -z "$SOQT_QTDIR"; then
    techo "WARNING: Qt not found."
  fi
  if test -n "$SOQT_QTDIR"; then
    SOQT_ENV="QTDIR=$SOQT_QTDIR $SOQT_ENV"
  fi
  SOQT_DBG_ENV="$SOQT_ENV"

# Find Coin
  local COIN_DIR=
  if $COIN_USE_REPO; then
    if test -d $BLDR_INSTALL_DIR/${COIN_NAME}-${FORPYTHON_SHARED_BUILD}/bin; then
      COIN_DIR=`(cd $BLDR_INSTALL_DIR/${COIN_NAME}-${FORPYTHON_SHARED_BUILD}; pwd -P)`
    fi
  else
    if test -d $CONTRIB_DIR/${COIN_NAME}-${FORPYTHON_SHARED_BUILD}/bin; then
      COIN_DIR=`(cd $CONTRIB_DIR/${COIN_NAME}-${FORPYTHON_SHARED_BUILD}; pwd -P)`
    fi
  fi
  if test -n "$COIN_DIR"; then
    local COIN_BINDIR=$COIN_DIR/bin
    SOQT_ENV="$SOQT_ENV PATH=$COIN_BINDIR:'$PATH'"
    if [[ `uname` =~ CYGWIN ]]; then
      local COIN_DBG_BINDIR=${COIN_DIR}dbg/bin
      SOQT_DBG_ENV="$SOQT_DBG_ENV PATH=$COIN_DBG_BINDIR:'$PATH'"
    fi
  fi
  trimvar SOQT_ENV ' '
  trimvar SOQT_DBG_ENV ' '

# Configure and build
  local otherargsvar=`genbashvar SOQT_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig -p $COIN_NAME-$COIN_BLDRVERSION-$FORPYTHON_SHARED_BUILD $SOQT_NAME $FORPYTHON_SHARED_BUILD "$COMPILERS_SOQT $SOQT_ADDL_ARGS $otherargs" "" "$SOQT_ENV"; then
    bilderBuild $SOQT_MAKER_ARGS $SOQT_NAME $FORPYTHON_SHARED_BUILD "" "$SOQT_ENV"
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
    bilderInstall $SOQT_MAKER_ARGS -L $SOQT_NAME $bld
  done
}


#!/bin/bash
#
# Build information for qwt
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in qwt_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/qwt_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setQwtNonTriggerVars() {
  QWT_UMASK=002
}
setQwtNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

#
# Build
#
buildQwt() {

# Get version and proceed
  if ! bilderUnpack qwt; then
    return 1
  fi

# This is installed into qt, which is in the contrib dir
  QWT_INSTALL_DIRS=$CONTRIB_DIR

  local makerargs=
  local qwtprefix="$CONTRIB_DIR/qwt-${QWT_BLDRVERSION}-$QWT_BUILD"
  case `uname` in
    CYGWIN*)
      makerargs="-m nmake"
      qwtprefix=`cygpath -am "$qwtprefix"`
      sed -i.bak -e "/^QWT_INSTALL_PREFIX_WIN32/s?=.*\$?= $qwtprefix?" $BUILD_DIR/qwt-${QWT_BLDRVERSION}/qwtconfig.pri
      ;;
    Darwin)
# Installing in qt to get framework as needed by visit
      qwtprefix="$CONTRIB_DIR/qt-${QT_BLDRVERSION}-$QT_BUILD"
      sed -i.bak -e "/^QWT_INSTALL_PREFIX_UNIX/s?=.*\$?= $qwtprefix?" $BUILD_DIR/qwt-${QWT_BLDRVERSION}/qwtconfig.pri
      ;;
    Linux)
      sed -i.bak -e "/^QWT_INSTALL_PREFIX_UNIX/s?=.*\$?= $qwtprefix?" $BUILD_DIR/qwt-${QWT_BLDRVERSION}/qwtconfig.pri
      ;;
  esac
  techo "Installing qwt into $qwtprefix."

  if bilderConfig $makerargs -q qwt.pro qwt $QWT_BUILD; then
    bilderBuild $makerargs qwt $QWT_BUILD
  fi
}

######################################################################
#
# Test
#
######################################################################

testQwt() {
  techo "Not testing qwt."
}

######################################################################
#
# Install
#
######################################################################

installQwt() {
  local instopts=
  case `uname` in
    CYGWIN*) ;;
    Darwin) instopts=-L;;
  esac
  if bilderInstall $instopts qwt $QWT_BUILD; then
    :
  fi
}

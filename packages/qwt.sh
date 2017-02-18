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
  qwtinstdir="$CONTRIB_DIR/qwt-${QWT_BLDRVERSION}-$QWT_BUILD"
  case `uname` in
    CYGWIN*)
      makerargs="-m nmake"
      qwtinstdir=`cygpath -aw "$qwtinstdir"`
      ;;
  esac
  if bilderConfig $makerargs -q qwt.pro qwt $QWT_BUILD "" "" "QWT_INSTALL_PREFIX='$qwtinstdir'"; then
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
# JRC 20130320: Qwt is installed from just "make all".
  if bilderInstall qwt $QWT_BUILD; then
    :
  fi
}

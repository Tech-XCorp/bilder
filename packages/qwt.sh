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
  case `uname` in
    CYGWIN*)
      case `uname -m` in
        i686) makerargs="-m nmake";;
      esac
      ;;
  esac
  if bilderConfig $makerargs -q qwt.pro qwt $QWT_BUILD "$QMAKESPECARG"; then
    local QWT_PLATFORM_BUILD_ARGS=
    case `uname`-`uname -r` in
      Darwin-1[2-3].*) QWT_PLATFORM_BUILD_ARGS="CXX=clang++";;
      CYGWIN*)     QWT_PLATFORM_BUILD_ARGS="CXX=$(basename "${CXX}")";;
      *)           QWT_PLATFORM_BUILD_ARGS="CXX=g++";;
    esac
# During testing, do not "make clean".
    bilderBuild $makerargs -k qwt $QWT_BUILD "all docs $QWT_PLATFORM_BUILD_ARGS"
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
  if bilderInstall -L -T all qwt $QWT_BUILD; then
    :
  fi
}

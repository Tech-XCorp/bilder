#!/bin/sh
######################################################################
#
# @file    ninja.sh
#
# @brief   Build information for ninja.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in ninja_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/ninja_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNinjaNonTriggerVars() {
  :
}
setNinjaNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildNinja() {
  NINJA_CONFIG_METHOD=none
  if bilderUnpack -i ninja; then
# No configure step, so must set build dir
    NINJA_SER_BUILD_DIR=$BUILD_DIR/ninja-$NINJA_BLDRVERSION/ser
    bilderBuild -kD -m ./bootstrap.py ninja ser
  fi
}

######################################################################
#
# Test
#
######################################################################

testNinja() {
  techo "Not testing ninja."
}

######################################################################
#
# Install ninja
#
######################################################################

installNinja() {
# No configure step, so must set installation dir
  NINJA_SER_INSTALL_DIR=$CONTRIB_DIR
  local exesfx=
  if [[ `uname` =~ CYGWIN ]]; then
    exesfx=.exe
  fi
  if bilderInstall -L -m ":" ninja ser; then
    local cmd="/usr/bin/install -m775 $BUILD_DIR/ninja-$NINJA_BLDRVERSION/ser/ninja${exesfx} $CONTRIB_DIR/bin"
    techo "$cmd"
    $cmd
  fi
}


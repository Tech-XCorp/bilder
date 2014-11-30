#!/bin/bash
#
# Build information for cppcheck
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in cppcheck_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/cppcheck_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCppcheckNonTriggerVars() {
  :
}
setCppcheckNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildCppcheck() {
  CPPCHECK_CONFIG_METHOD=none
  if bilderUnpack -i cppcheck; then
# No configure step, so must set build dir
    CPPCHECK_SER_BUILD_DIR=$BUILD_DIR/cppcheck-$CPPCHECK_BLDRVERSION/ser
    local makerargs=
    if [[ `uname` =~ CYGWIN ]]; then
      makerargs="-m build.bat"
    fi
    bilderBuild -kD -m ./bootstrap.py cppcheck ser
  fi
}

######################################################################
#
# Test
#
######################################################################

testCppcheck() {
  techo "Not testing cppcheck."
}

######################################################################
#
# Install cppcheck
#
######################################################################

installCppcheck() {
# No configure step, so must set installation dir
  CPPCHECK_SER_INSTALL_DIR=$CONTRIB_DIR
  local exesfx=
  if [[ `uname` =~ CYGWIN ]]; then
    exesfx=.exe
  fi
  if bilderInstall -L -m ":" cppcheck ser; then
    local cmd="/usr/bin/install -m775 $BUILD_DIR/cppcheck-$CPPCHECK_BLDRVERSION/ser/cppcheck${exesfx} $CONTRIB_DIR/bin"
    techo "$cmd"
    $cmd
  fi
}


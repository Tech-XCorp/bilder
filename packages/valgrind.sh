#!/bin/bash
#
# Build information for valgrind
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in valgrind_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/valgrind_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setValgrindNonTriggerVars() {
  VALGRIND_MASK=002
}
setValgrindNonTriggerVars

######################################################################
#
# Launch valgrind builds.
#
######################################################################

buildValgrind() {

# VALGRIND must be built in place
  if ! bilderUnpack -i valgrind; then
    return
  fi

# Test for unpacked as ser
  if test -d $BUILD_DIR/valgrind-$VALGRIND_BLDRVERSION/ser; then
    cmd="cd $BUILD_DIR/valgrind-$VALGRIND_BLDRVERSION/ser"
    techo "$cmd"
    $cmd
    if test -x autogen.sh; then
      cmd="./autogen.sh"
      techo "$cmd"
      $cmd
    fi
    cd -
    if test `uname` = Darwin; then
      VALGRIND_ENV="SDKROOT=`xcrun --show-sdk-path`"
    fi
    if bilderConfig -i valgrind ser "$VALGRIND_SER_OTHER_ARGS" "" "$VALGRIND_ENV"; then
      bilderBuild valgrind ser "" "$VALGRIND_ENV"
    fi
  fi

}

######################################################################
#
# Test valgrind
#
######################################################################

testValgrind() {
  techo "Not testing valgrind."
}

######################################################################
#
# Install valgrind
#
######################################################################

installValgrind() {
  bilderInstall valgrind ser valgrind "" "$VALGRIND_ENV"
}


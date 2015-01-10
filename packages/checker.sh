#!/bin/bash
#
# Build information for checker
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in checker_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/checker_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCheckerNonTriggerVars() {
  CHECKER_UMASK=002
}
setCheckerNonTriggerVars

#####################################################################
#
# Launch checker builds.
#
######################################################################

buildChecker() {

# Get checker, check for build need
  CHECKER_CONFIG_METHOD=none
  if ! bilderUnpack checker; then
    return
  fi

# Copy to contrib
  CHECKER_SER_INSTALL_DIR=$CONTRIB_DIR
  CHECKER_SER_BUILD_DIR=$BUILD_DIR/checker-$CHECKER_BLDRVERSION
  cmd="cp -R $BUILD_DIR/checker-$CHECKER_BLDRVERSION $CONTRIB_DIR"
  techo "$cmd"
  eval "$cmd"
# Build nothing
  bilderBuild -m : checker ser

}

######################################################################
#
# Test checker
#
######################################################################

testChecker() {
  techo "Not testing checker."
}

######################################################################
#
# Install checker
#
######################################################################

installChecker() {
  bilderInstall -m : -p open checker ser
}


#!/bin/bash
#
# Build information for ndiff
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in ndiff_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/ndiff_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setNdiffNonTriggerVars() {
  NDIFF_UMASK=002
}
setNdiffNonTriggerVars

######################################################################
#
# Launch ndiff builds.
#
######################################################################

buildNdiff() {

# Unpack
  if ! bilderUnpack ndiff; then
    return 1
  fi

  techo "NDIFF_BLDRVERSION = $NDIFF_BLDRVERSION."

#  if bilderConfig -g -i -B ser ndiff ser "" "ndiff" "$NDIFF_SER_ENV"; then
  if bilderConfig -g -i -B pycsh ndiff pycsh "" "ndiff" "$NDIFF_PYCSH_ENV"; then
    bilderBuild ndiff pycsh "" "TARGET_ARCH=''"
  fi

}

######################################################################
#
# Test ndiff
#
######################################################################

testNdiff() {
  techo "Not testing ndiff."
}

######################################################################
#
# Install ndiff
#
######################################################################

# Set umask to allow only group to use
installNdiff() {
  mkdir -p $CONTRIB_DIR/ndiff
  mkdir -p $CONTRIB_DIR/ndiff/bin
  mkdir -p $CONTRIB_DIR/ndiff/man
  mkdir -p $CONTRIB_DIR/ndiff/man/man1
  bilderInstall -L ndiff pycsh
}


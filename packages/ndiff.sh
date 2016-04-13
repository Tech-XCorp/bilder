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

  if bilderConfig ndiff ser "$CONFIG_COMPILERS_SER --enable-static $NDIFF_SER_ADDL_ARGS" "" "$NDIFF_SER_ENV"; then
    bilderBuild ndiff ser "" ""
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
  bilderInstall ndiff ser
}


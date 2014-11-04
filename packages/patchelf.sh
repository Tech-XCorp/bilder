#!/bin/bash
#
# Build information for patchelf
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in patchelf_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/patchelf_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPatchelfNonTriggerVars() {
  PATCHELF_UMASK=002
}
setPatchelfNonTriggerVars

######################################################################
#
# Launch Patchelf builds.
#
######################################################################

buildPatchelf() {
# If executable not found, under prefix, needs installing
  if ! test -x $CONTRIB_DIR/bin/patchelf; then
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR patchelf,ser
  fi
# Build
  if ! bilderUnpack patchelf; then
    return
  fi
  if bilderConfig -p - patchelf ser; then
    bilderBuild -m make patchelf ser
  fi
}

######################################################################
#
# Test patchelf
#
######################################################################

testPatchelf() {
  techo "Not testing patchelf."
}

######################################################################
#
# Install patchelf
#
######################################################################

installPatchelf() {
  bilderInstall -m make patchelf ser autotools
}

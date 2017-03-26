#!/bin/sh
######################################################################
#
# @file    patchelf.sh
#
# @brief   Build information for patchelf.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
  if ! bilderUnpack patchelf; then
    return
  fi
  if bilderConfig patchelf ser; then
    bilderBuild patchelf ser
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
  if bilderInstall patchelf ser; then
    local cmd="(cd $CONTRIB_DIR/bin; ln -sf ../patchelf/bin/patchelf .)"
    techo "$cmd"
    eval "$cmd"
  fi
}

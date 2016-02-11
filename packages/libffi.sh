#!/bin/bash
#
# Build information for libffi
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in libffi_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/libffi_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLibffiNonTriggerVars() {
  LIBFFI_UMASK=002
}
setLibffiNonTriggerVars

######################################################################
#
# Launch libffi builds.
#
######################################################################

buildLibffi() {
# Unpack
  if ! bilderUnpack libffi; then
    return
  fi
# Build
  if bilderConfig libffi sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $LIBFFI_SER_OTHER_ARGS"; then
    bilderBuild libffi sersh
  fi
  if bilderConfig libffi pycsh "--enable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $LIBFFI_SER_OTHER_ARGS"; then
    bilderBuild libffi pycsh
  fi
}

######################################################################
#
# Test libffi
#
######################################################################

testLibffi() {
  techo "Not testing libffi."
}

######################################################################
#
# Install libffi
#
######################################################################

installLibffi() {
  bilderInstall libffi sersh
}


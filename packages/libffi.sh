#!/bin/sh
######################################################################
#
# @file    libffi.sh
#
# @brief   Build information for libffi.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
  if bilderConfig libffi ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $LIBFFI_SER_OTHER_ARGS"; then
    bilderBuild libffi ser
  fi
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
  bilderInstall libffi pycsh
  bilderInstall libffi ser
}


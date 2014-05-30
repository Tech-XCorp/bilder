#!/bin/bash
#
# Build information for pcre
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pcre_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pcre_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPcreNonTriggerVars() {
  PCRE_UMASK=002
}
setPcreNonTriggerVars

######################################################################
#
# Launch pcre builds.
#
######################################################################

buildPcre() {
  if ! bilderUnpack pcre; then
    return
  fi
# PCRE built with cmake does not install pcre-config, which swig needs.
  if bilderConfig pcre ser; then
    bilderBuild pcre ser
  fi
}

######################################################################
#
# Test pcre
#
######################################################################

testPcre() {
  techo "Not testing pcre."
}

######################################################################
#
# Install pcre
#
######################################################################

installPcre() {
  bilderInstall -r pcre ser
}


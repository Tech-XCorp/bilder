#!/bin/bash
#
# Build information for libgd
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in libgd_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/libgd_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLibgdNonTriggerVars() {
  LIBGD_UMASK=002
}
setLibgdNonTriggerVars

######################################################################
#
# Launch libgd builds.
#
######################################################################

buildLibgd() {

  if ! bilderUnpack libgd; then
    return 1
  fi

  if bilderConfig -c libgd ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER"; then
    bilderBuild libgd ser
  fi

}

######################################################################
#
# Test libgd
#
######################################################################

testLibgd() {
  techo "Not testing libgd."
}

######################################################################
#
# Install libgd
#
######################################################################

installLibgd() {
  bilderInstallAll libgd
}


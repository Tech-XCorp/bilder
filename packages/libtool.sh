#!/bin/bash
#
# Build information for libtool
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in libtool_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/libtool_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLibtoolNonTriggerVars() {
  LIBTOOL_UMASK=002
}
setLibtoolNonTriggerVars

######################################################################
#
# Launch libtool builds.
#
######################################################################

buildLibtool() {
  if ! bilderUnpack libtool; then
    return
  fi
  if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION libtool ser; then
    bilderBuild -m make libtool ser
  fi
}

######################################################################
#
# Test libtool
#
######################################################################

testLibtool() {
  techo "Not testing libtool."
}

######################################################################
#
# Install libtool
#
######################################################################

installLibtool() {
  local instenv=
  which /usr/bin/install 1>/dev/null 2>&1 && instenv="INSTALL=/usr/bin/install"
  bilderInstall -m make libtool ser autotools "$instenv"
}


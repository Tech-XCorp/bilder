#!/bin/sh
######################################################################
#
# @file    autoconf.sh
#
# @brief   Build information for autoconf
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in autoconf_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/autoconf_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setAutoconfNonTriggerVars() {
  AUTOCONF_UMASK=002
}
setAutoconfNonTriggerVars

######################################################################
#
# Launch autoconf builds.
#
######################################################################

buildAutoconf() {
# If executable not found, under prefix, needs installing
  if ! test -x $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/autoconf; then
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR autoconf,ser
  fi
# Build
  if ! bilderUnpack autoconf; then
    return
  fi
  if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION autoconf ser; then
    bilderBuild -m make autoconf ser
  fi
}

######################################################################
#
# Test autoconf
#
######################################################################

testAutoconf() {
  techo "Not testing autoconf."
}

######################################################################
#
# Install autoconf
#
######################################################################

installAutoconf() {
  bilderInstall -m make autoconf ser autotools
}


#!/bin/bash
#
# Build information for m4
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in m4_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/m4_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setM4NonTriggerVars() {
  M4_UMASK=002
}
setM4NonTriggerVars

######################################################################
#
# Launch m4 builds.
#
######################################################################

buildM4() {
# If executable not found, under prefix, needs installing
  if ! test -x $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/m4; then
    techo "Executable, $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/m4, not found."
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR m4,ser
  fi
# On to the regular build
  if ! bilderUnpack m4; then
    return
  fi
# Cannot add all cflags to m4, as there are no flags that correspond to
# the cygwin build.
  if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION m4 ser "CFLAGS='-fgnu89-inline'"; then
    bilderBuild -m make m4 ser
  fi
}

######################################################################
#
# Test m4
#
######################################################################

testM4() {
  techo "Not testing m4."
}

######################################################################
#
# Install m4
#
######################################################################

installM4() {
  bilderInstall -m make m4 ser autotools
}


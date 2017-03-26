#!/bin/sh
######################################################################
#
# @file    tulip.sh
#
# @brief   Version and build information for tulip.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in tulip_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/tulip_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTulipNonTriggerVars() {
  TULIP_MASK=002
}
setTulipNonTriggerVars

######################################################################
#
# Launch tulip builds.
#
######################################################################

buildTulip() {

  if ! bilderUnpack tulip; then
    return 1
  fi

# Set up variables
# build_visit sets both of these the same for Darwin
  if bilderConfig tulip $FORPYTHON_SHARED_BUILD "$TULIP_CONFIG_ARGS" "" "$TULIP_ENV"; then
    bilderBuild $TULIP_MAKER_ARGS tulip $FORPYTHON_SHARED_BUILD "$TULIP_MAKE_ARGS" "$TULIP_ENV"
  fi

}

######################################################################
#
# Test tulip
#
######################################################################

testTulip() {
  techo "Not testing tulip."
}

######################################################################
#
# Install tulip
#
######################################################################

installTulip() {
  bilderInstall $TULIP_MAKER_ARGS -r $TULIP_NAME $FORPYTHON_SHARED_BUILD "" "" "$TULIP_ENV"
}


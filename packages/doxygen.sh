#!/bin/bash
#
# Version and build information for doxygen
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in aux script
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/doxygen_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value 
# change here do not, so that build gets triggered by change of this 
# file. E.g: mask
#
######################################################################

#setDoxygenNonTriggerVars() {
#  :
#}
#setDoxygenNonTriggerVars

######################################################################
#
# Launch doxygen builds.
#
######################################################################

buildDoxygen() {
  if bilderUnpack -i doxygen; then
    if bilderConfig -i -n -p - doxygen ser; then
      bilderBuild doxygen ser
    fi
  fi
}

######################################################################
#
# Test doxygen
#
######################################################################

testDoxygen() {
  techo "Not testing doxygen."
}

######################################################################
#
# Install doxygen
#
######################################################################

installDoxygen() {
# Ignore installation errors.  Doxygen tries to set perms of /contrib/bin.
  bilderInstall -p open doxygen ser "" "-i"
# Because doxygen mucks with perms, have to reset
  setOpenPerms $CONTRIB_DIR/bin
}


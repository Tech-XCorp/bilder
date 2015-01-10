#!/bin/bash
#
# Version and build information for autotools
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in autotools_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/autotools_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setAutotoolsNonTriggerVars() {
  AUTOTOOLS_MASK=002
}
setAutotoolsNonTriggerVars

######################################################################
#
# Launch autotools builds.
#
######################################################################

buildAutotools() {
  :
}

######################################################################
#
# Test autotools 
#
######################################################################

testAutotools() {
  echo "Not testing autotools."
}

######################################################################
#
# Install autotools 
#
######################################################################

installAutotools() {
  :
  # techo "WARNING: Quitting at end of installAutotools."; cleanup
}



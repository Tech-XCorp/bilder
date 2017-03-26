#!/bin/sh
######################################################################
#
# @file    autotools.sh
#
# @brief   Version and build information for autotools
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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


#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setChrpathTriggerVars() {
  CHRPATH_BLDRVERSION=${CHRPATH_BLDRVERSION:-"0.13"}
  if test `uname` = Linux && ! which chrpath 1>/dev/null; then
    CHRPATH_BUILDS=${CHRPATH_BUILDS:-"ser"}
  fi
  CHRPATH_DEPS=
  CHRPATH_UMASK=002
}
setChrpathTriggerVars

######################################################################
#
# Find oce
#
######################################################################

# Find the directory containing the OCE cmake files
findChrpath() {
  :
}


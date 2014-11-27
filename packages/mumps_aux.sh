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

setMumpsTriggerVars() {
  MUMPS_BLDRVERSION=${MUMPS_BLDRVERSION:-"4.10.0"}
  test `uname` = Linux && MUMPS_BUILDS=${MUMPS_BUILDS:-"ser,par"}
  MUMPS_DEPS=cmake
}
setMumpsTriggerVars

######################################################################
#
# Find mumps
#
######################################################################

findMumps() {
  :
}


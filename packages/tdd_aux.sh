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

setTddTriggerVars() {
  TDD_BLDRVERSION=${TDD_BLDRVERSION:-"43_20140724oss"}
  TDD_BUILDS=${TDD_BUILDS:-"ser,sersh"}
  addCc4pyBuild tdd
  TDD_DEPS=
}
setTddTriggerVars

######################################################################
#
# Find tdd
#
######################################################################

findTdd() {
  :
}


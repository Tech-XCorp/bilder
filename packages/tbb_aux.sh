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

setTbbTriggerVars() {
  TBB_BLDRVERSION=${TBB_BLDRVERSION:-"43_20140724oss"}
  TBB_BUILDS=${TBB_BUILDS:-"sersh"}
  addCc4pyBuild tbb
  TBB_DEPS=
}
setTbbTriggerVars

######################################################################
#
# Find tbb
#
######################################################################

findTbb() {
  :
}


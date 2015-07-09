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

setSwigTriggerVars() {
  SWIG_BLDRVERSION_STD=2.0.8
  SWIG_BLDRVERSION_EXP=2.0.8
  SWIG_BUILDS=${SWIG_BUILDS:-"ser"}
  SWIG_DEPS=pcre
}
setSwigTriggerVars

######################################################################
#
# Find swig
#
######################################################################

findSwig() {
  addtopathvar PATH $CONTRIB_DIR/swig/bin
}


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

setPcreTriggerVars() {
  PCRE_BLDRVERSION=${PCRE_BLDRVERSION:-"8.20"}
  PCRE_BUILDS=${PCRE_BUILDS:-"ser"}
  PCRE_DEPS=
}
setPcreTriggerVars

######################################################################
#
# Find swig
#
######################################################################

findPcre() {
  addtopathvar PATH $CONTRIB_DIR/pcre/bin
}


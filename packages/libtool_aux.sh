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

setLibtoolTriggerVars() {
  LIBTOOL_BLDRVERSION_STD=${LIBTOOL_BLDRVERSION_STD:-"2.4.2"}
  LIBTOOL_BLDRVERSION_EXP=${LIBTOOL_BLDRVERSION_EXP:-"2.4.2"}
  computeVersion libtool
}
setLibtoolTriggerVars

######################################################################
#
# Find libtool
#
######################################################################

findLibtool() {
  addtopathvar PATH $CONTRIB_DIR/autotools/bin
}


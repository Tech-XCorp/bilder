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

setM4TriggerVars() {
  M4_BLDRVERSION_STD=${M4_BLDRVERSION_STD:-"1.4.17"}
  M4_BLDRVERSION_EXP=${M4_BLDRVERSION_EXP:-"1.4.17"}
  M4_BUILDS=${M4_BUILDS:-"ser"}
  M4_DEPS=xz
# Libtool determines the installation prefix
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
}
setM4TriggerVars

######################################################################
#
# Find m4
#
######################################################################

findM4() {
  addtopathvar PATH $CONTRIB_DIR/autotools/bin
}


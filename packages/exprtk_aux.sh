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

setExprtkTriggerVars() {
  EXPRTK_BLDRVERSION_STD=${EXPRTK_BLDRVERSION_STD:-"1.0.0"}
  EXPRTK_BLDRVERSION_EXP=${EXPRTK_BLDRVERSION_EXP:-"1.0.0"}
  EXPRTK_BUILDS=${EXPRTK_BUILDS:-"ser"}
}
setExprtkTriggerVars

######################################################################
#
# Find exprtk
#
######################################################################

findExprtk() {
  addtopathvar PATH $CONTRIB_DIR/exprtk/bin
}


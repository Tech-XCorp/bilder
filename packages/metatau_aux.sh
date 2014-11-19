#!/bin/bash
#
# Trigger vars and find information
#
# $Id: metatau_aux.sh 1438 2014-05-25 13:26:28Z jrobcary $
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

setMetatauTriggerVars() {
  METATAU_BLDRVERSION_STD=${METATAU_BLDRVERSION_STD:-"2.21.1"}
  METATAU_BLDRVERSION_EXP=${METATAU_BLDRVERSION_EXP:-"2.21.1"}
  METATAU_BUILDS=${METATAU_BUILDS:-"par"}
  METATAU_DEPS=$MPI_BUILD
}
setMetatauTriggerVars

######################################################################
#
# Find metatau
#
######################################################################

findMetatau() {
  addtopathvar PATH $CONTRIB_DIR/tau/bin
}


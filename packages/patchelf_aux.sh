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

setAutoconfTriggerVars() {
  PATCHELF_BLDRVERSION_STD=${PATCHELF_BLDRVERSION_STD:-"0.8"}
  PATCHELF_BLDRVERSION_EXP=${PATCHELF_BLDRVERSION_EXP:-"0.8"}
  PATCHELF_BUILDS=${PATCHELF_BUILDS:-"ser"}
  PATCHELF_DEPS=
}
setPatchelfTriggerVars

######################################################################
#
# Find patchelf
#
######################################################################

findPatchelf() {
  addtopathvar PATH $CONTRIB_DIR/bin
}


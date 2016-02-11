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

setLibffiTriggerVars() {
  LIBFFI_BLDRVERSION_STD=${LIBFFI_BLDRVERSION_STD:-"3.2.1"}
  LIBFFI_BLDRVERSION_EXP=${LIBFFI_BLDRVERSION_EXP:-"3.2.1"}
  if test `uname` = Linux; then
    LIBFFI_BUILDS=${LIBFFI_BUILDS:-"pycsh,pycst"}
  fi
  LIBFFI_DEPS="libtool,pkgconfig"
}
setLibffiTriggerVars

######################################################################
#
# Find libffi
#
######################################################################

findLibffi() {
  findContribPackage Libffi libffi-3 sersh pycsh
  findPycshDir Libffi
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/libffi-${LIBFFI_BLDRVERSION}-sersh/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/libffi-${LIBFFI_BLDRVERSION}-sersh/lib
  printvar LD_LIBRARY_PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/libffi-${LIBFFI_BLDRVERSION}-sersh/lib
  printvar LD_RUN_PATH
}


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

setOrcTriggerVars() {
  ORC_BLDRVERSION_STD=${ORC_BLDRVERSION_STD:-"0.4.16"}
  ORC_BLDRVERSION_EXP=${ORC_BLDRVERSION_EXP:-"0.4.16"}
  if test `uname` = Linux; then
    ORC_BUILDS=${ORC_BUILDS:-"$FORPYTHON_SHARED_BUILD","$FORPYTHON_STATIC_BUILD,ser"}
  fi
  ORC_DEPS="libtool,pkgconfig"
}
setOrcTriggerVars

######################################################################
#
# Find orc
#
######################################################################

findOrc() {
  findContribPackage Orc orc-0.4 sersh pycsh
  findPycshDir Orc
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/bin
  printvar PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_LIBRARY_PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/orc-${ORC_BLDRVERSION}-${FORPYTHON_SHARED_BUILD}/lib
  printvar LD_RUN_PATH
}


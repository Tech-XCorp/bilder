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

setBisonTriggerVars() {
  BISON_BLDRVERSION_STD=${BISON_BLDRVERSION_STD:-"2.7.1"}
  BISON_BLDRVERSION_EXP=${BISON_BLDRVERSION_EXP:-"2.7.1"}
  if test `uname` = Linux; then
    BISON_BUILDS=${BISON_BUILDS:-"$FORPYTHON_SHARED_BUILD","$FORPYTHON_STATIC_BUILD"}
  fi
  BISON_DEPS="libtool,pkgconfig"
}
setBisonTriggerVars

######################################################################
#
# Find bison
#
######################################################################

findBison() {
  findContribPackage Bison bison-2.7 sersh pycsh
  findPycshDir Bison
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/bison-${BISON_BLDRVERSION}-sersh/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/bison-${BISON_BLDRVERSION}-sersh/lib
  printvar LD_LIBRARY_PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/bison-${BISON_BLDRVERSION}-sersh/lib
  printvar LD_RUN_PATH
}


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

setGlib2TriggerVars() {
  GLIB2_BLDRVERSION_STD=${GLIB2_BLDRVERSION_STD:-"2.38.2"}
  GLIB2_BLDRVERSION_EXP=${GLIB2_BLDRVERSION_EXP:-"2.38.2"}
  if test `uname` = Linux; then
    GLIB2_BUILDS=${GLIB2_BUILDS:-"$FORPYTHON_SHARED_BUILD","$FORPYTHON_STATIC_BUILD"}
  fi
  GLIB2_DEPS="libtool,pkgconfig,libffi"
}
setGlib2TriggerVars

######################################################################
#
# Find glib2
#
######################################################################

findGlib2() {
  findContribPackage Glib2 glib2 sersh pycsh
  findPycshDir Glib2
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/glib2-${GLIB2_BLDRVERSION}-sersh/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/glib2-${GLIB2_BLDRVERSION}-sersh/lib
  printvar LD_LIBRARY_PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/glib2-${GLIB2_BLDRVERSION}-sersh/lib
  printvar LD_RUN_PATH
}


#!/bin/bash
#
# Trigger vars and find information
#
# Package retarred from sqlite-autoconf-3070800.tar.gz:
# tar xzf sqlite-autoconf-3070800.tar.gz
# mv sqlite-autoconf-3070800 sqlite-3070800
# tar czf sqlite-3070800.tar.gz sqlite-3070800
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

setSqliteTriggerVars() {
  SQLITE_BLDRVERSION_STD=${SQLITE_BLDRVERSION_STD:-"3080200"}
  SQLITE_BLDRVERSION_EXP=${SQLITE_BLDRVERSION_EXP:-"3081002"}
  SQLITE_BUILDS=${SQLITE_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  SQLITE_BUILD=$FORPYTHON_SHARED_BUILD
  SQLITE_DEPS=
}
setSqliteTriggerVars

######################################################################
#
# Find sqlite
#
######################################################################

findSqlite() {
  :
}


#!/bin/bash
#
# Build information for sqlite.
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in sqlite_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/sqlite_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setXzNonTriggerVars() {
  SQLITE_UMASK=002
}
setXzNonTriggerVars

######################################################################
#
# Launch sqlite builds.
#
######################################################################

buildSqlite() {
  if ! bilderUnpack sqlite; then
    return
  fi
  if bilderConfig sqlite $SQLITE_BUILD; then
    bilderBuild sqlite $SQLITE_BUILD
  fi
}

######################################################################
#
# Test sqlite
#
######################################################################

testSqlite() {
  techo "Not testing sqlite."
}

######################################################################
#
# Install sqlite
#
######################################################################

installSqlite() {
  bilderInstall sqlite $SQLITE_BUILD
}


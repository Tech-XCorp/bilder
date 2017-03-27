#!/bin/sh
######################################################################
#
# @file    sqlite.sh
#
# @brief   Build information for sqlite.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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


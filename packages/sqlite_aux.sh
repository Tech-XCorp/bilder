#!/bin/sh
######################################################################
#
# @file    sqlite_aux.sh
#
# @brief   Trigger vars and find information fo sqlite.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# Package retarred from sqlite-autoconf-3160000.tar.gz:
# tar xzf sqlite-autoconf-3160000.tar.gz
# mv sqlite-autoconf-3160000 sqlite-3160000
# env COPYFILE_DISABLE=true tar czf sqlite-3160000.tar.gz sqlite-3160000
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
  SQLITE_BLDRVERSION_STD=${SQLITE_BLDRVERSION_STD:-"3160000"}
  SQLITE_BLDRVERSION_EXP=${SQLITE_BLDRVERSION_EXP:-"3160000"}
# Apparently sqlite does build on Windows?
  # case `uname` in
  # Linux | Darwin)
  SQLITE_BUILDS=${SQLITE_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  # ;;
  # esac
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


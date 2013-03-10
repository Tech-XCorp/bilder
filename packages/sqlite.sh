#!/bin/bash
#
# Version and build information for sqlite.
#
# $Id$
#
######################################################################

######################################################################
#
# Version
# Package retarred from sqlite-autoconf-3070800.tar.gz:
# tar xzf sqlite-autoconf-3070800.tar.gz
# mv sqlite-autoconf-3070800 sqlite-3070800
# tar czf sqlite-3070800.tar.gz sqlite-3070800
#
######################################################################

SQLITE_BLDRVERSION=${SQLITE_BLDRVERSION:-"3070800"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

SQLITE_BUILDS=${SQLITE_BUILDS:-"$FORPYTHON_BUILD"}
SQLITE_BUILD=$FORPYTHON_BUILD
SQLITE_DEPS=
SQLITE_UMASK=002

######################################################################
#
# Launch sqlite builds.
#
######################################################################

buildSqlite() {
  if bilderUnpack sqlite; then
    if bilderConfig sqlite $SQLITE_BUILD; then
      bilderBuild sqlite $SQLITE_BUILD
    fi
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


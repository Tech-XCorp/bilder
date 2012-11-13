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
# Other values
#
######################################################################

if test -z "$SQLITE_BUILDS"; then
  case `uname` in
    Linux)
      SQLITE_BUILDS=ser
      ;;
  esac
fi
SQLITE_DEPS=
SQLITE_UMASK=002

######################################################################
#
# Launch sqlite builds.
#
######################################################################

buildSqlite() {
  if bilderUnpack sqlite; then
    if bilderConfig sqlite ser; then
      bilderBuild sqlite ser
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
  bilderInstall sqlite ser
}


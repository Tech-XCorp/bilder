#!/bin/sh
######################################################################
#
# @file    readline.sh
#
# @brief   Version and build information for readline.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

READLINE_BLDRVERSION=${READLINE_BLDRVERSION:-"6.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setReadlineGlobalVars() {
# We need readlin for old Darwin only
  if [[ `uname` =~ Darwin ]]; then
    local dver=`uname -r | sed -e 's/\..*$//'`
    if test $dver -lt 11; then
      READLINE_BUILDS=${READLINE_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
    fi
  fi
  READLINE_BUILD=$FORPYTHON_SHARED_BUILD
  READLINE_DEPS=ncurses
}
setReadlineGlobalVars

######################################################################
#
# Launch readline builds.
#
######################################################################

buildReadline() {
  if ! bilderUnpack readline; then
    return 1
  fi
  if bilderConfig readline $READLINE_BUILD "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $READLINE_CONFIG_LDFLAGS"; then
    bilderBuild readline $READLINE_BUILD
  fi
}

######################################################################
#
# Test readline
#
######################################################################

testReadline() {
  techo "Not testing readline."
}

######################################################################
#
# Install readline
#
######################################################################

installReadline() {
  bilderInstall readline $READLINE_BUILD
}


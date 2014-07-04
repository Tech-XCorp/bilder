#!/bin/bash
#
# Version and build information for Ncurses
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

NCURSES_BLDRVERSION=${NCURSES_BLDRVERSION:-"5.9"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setNcursesGlobalVars() {
# We need ncurses for old Darwin only
  if [[ `uname` =~ Darwin ]]; then
    local dver=`uname -r | sed -e 's/\..*$//'`
    if test $dver -lt 11; then
      NCURSES_BUILDS=${NCURSES_BUILDS:-"$FORPYTHON_BUILD"}
    fi
  fi
  NCURSES_BUILD=$FORPYTHON_BUILD
  NCURSES_DEPS=
}
setNcursesGlobalVars

######################################################################
#
# Launch ncurses builds
#
######################################################################

buildNcurses() {
  if ! bilderUnpack ncurses; then
    return 1
  fi
  local otherargsvar=`genbashvar NCURSES_${NCURSES_BUILD}_OTHER_ARGS`
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig ncurses ${NCURSES_BUILD} "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $otherargs"; then
    bilderBuild ncurses ${NCURSES_BUILD}
  fi
}

######################################################################
#
# Test ncurses
#
######################################################################

testNcurses() {
  techo "Not testing ncurses."
}

######################################################################
#
# Install
#
######################################################################

installNcurses() {
  bilderInstall ncurses ${NCURSES_BUILD}
}


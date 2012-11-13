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
NCURSES_BUILDS=${NCURSES_BUILDS:-"cc4py"}
NCURSES_DEPS=

######################################################################
#
# We only need ncurses and readline for Darwin: Windows doesn't work 
#  and it's standard on linux
#
######################################################################
case `uname` in
  CYGWIN*)
	  unset NCURSES_BUILDS
	  ;;
  Linux)
	  unset NCURSES_BUILDS
    ;;
esac

######################################################################
#
# Launch R builds.
#
######################################################################

buildNcurses() {
  if bilderUnpack ncurses; then
    if bilderConfig ncurses ser "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $NCURSES_CONFIG_LDFLAGS"; then
      bilderBuild ncurses ser
    fi
  fi
}

######################################################################
#
# Test 0mq
#
######################################################################

testNcurses() {
  techo "Not testing ncurses."
}

######################################################################
#
# Install R
#
######################################################################

installNcurses() {
# Ignore installation errors.  R tries to set perms of /contrib/bin.
  bilderInstall ncurses ser "" ""
}


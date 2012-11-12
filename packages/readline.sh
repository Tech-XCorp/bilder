#!/bin/bash
#
# Version and build information for Readline
#
# $Id: readline.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

READLINE_BLDRVERSION=${READLINE_BLDRVERSION:-"6.2"}
READLINE_BUILDS=${READLINE_BUILDS:-"cc4py"}
READLINE_DEPS=ncurses

######################################################################
#
# We only need ncurses and readline for Darwin: Windows doesn't work 
#  and it's standard on linux
#
######################################################################
case `uname` in
  CYGWIN*)
	  unset READLINE_BUILDS
	  ;;
  Linux)
	  unset READLINE_BUILDS
    ;;
esac

######################################################################
#
# Launch R builds.
#
######################################################################

buildReadline() {
  if bilderUnpack readline; then
    if bilderConfig readline ser "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $READLINE_CONFIG_LDFLAGS"; then
      bilderBuild readline ser
    fi
  fi
}

######################################################################
#
# Test 0mq
#
######################################################################

testReadline() {
  techo "Not testing readline."
}

######################################################################
#
# Install R
#
######################################################################

installReadline() {
# Ignore installation errors.  R tries to set perms of /contrib/bin.
  bilderInstall readline ser "" ""
}


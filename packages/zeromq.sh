#!/bin/bash
#
# Version and build information for ZeroMQ
#
# $Id: zeromq.sh 4858 2012-01-11 19:13:22Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

ZEROMQ_BLDRVERSION=${ZEROMQ_BLDRVERSION:-"2.1.11"}
ZEROMQ_BUILDS=${ZEROMQ_BUILDS:-"ser"}
ZEROMQ_DEPS=

######################################################################
#
# Other values
#
######################################################################
case `uname` in
    CYGWIN*)
	unset ZEROMQ_BUILDS
	;;
esac

######################################################################
#
# Launch R builds.
#
######################################################################

buildZeromq() {
  if bilderUnpack zeromq; then
    if bilderConfig zeromq ser "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $ZEROMQ_CONFIG_LDFLAGS"; then
      bilderBuild zeromq ser
    fi
  fi
}

######################################################################
#
# Test 0mq
#
######################################################################

testZeromq() {
  techo "Not testing zeromq."
}

######################################################################
#
# Install R
#
######################################################################

installZeromq() {
# Ignore installation errors.  R tries to set perms of /contrib/bin.
  bilderInstall zeromq ser "" ""
}


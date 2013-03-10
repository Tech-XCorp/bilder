#!/bin/bash
#
# Version and build information for ZeroMQ
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

ZEROMQ_BLDRVERSION=${ZEROMQ_BLDRVERSION:-"2.1.11"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$ZEROMQ_BUILDS"; then
  if ! [[ `uname` =~ CYGWIN ]]; then
    ZEROMQ_BUILDS=$FORPYTHON_BUILD
  fi
fi
ZEROMQ_BUILD=$FORPYTHON_BUILD
ZEROMQ_DEPS=
ZEROMQ_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildZeromq() {
  if bilderUnpack zeromq; then
    if bilderConfig zeromq $ZEROMQ_BUILD "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $ZEROMQ_CONFIG_LDFLAGS"; then
      bilderBuild zeromq $ZEROMQ_BUILD
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testZeromq() {
  techo "Not testing zeromq."
}

######################################################################
#
# Install
#
######################################################################

installZeromq() {
# Ignore installation errors.  R tries to set perms of /contrib/bin.
# 20121202: Is this true?  Copy-paste error?
  bilderInstall zeromq $ZEROMQ_BUILD
}


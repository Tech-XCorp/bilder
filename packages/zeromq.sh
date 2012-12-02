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
    ZEROMQ_BUILDS="cc4py"
  fi
fi
ZEROMQ_DEPS=

######################################################################
#
# Launch builds.
#
######################################################################

buildZeromq() {
  if bilderUnpack zeromq; then
    if bilderConfig zeromq cc4py "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $ZEROMQ_CONFIG_LDFLAGS"; then
      bilderBuild zeromq cc4py
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
  bilderInstall zeromq cc4py
}


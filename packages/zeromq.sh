#!/bin/bash
#
# Version and build information for ZeroMQ
# http://zeromq.org/intro:get-the-software
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

ZEROMQ_BLDRVERSION=${ZEROMQ_BLDRVERSION_EXP:-"4.0.3"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setZeromqGlobalVars() {
  if ! [[ `uname` =~ CYGWIN ]]; then
    ZEROMQ_BUILDS=${ZEROMQ_BUILDS:-"$FORPYTHON_BUILD"}
  fi
  ZEROMQ_BUILD=$FORPYTHON_BUILD
  ZEROMQ_DEPS=
  ZEROMQ_UMASK=002
}
setZeromqGlobalVars

######################################################################
#
# Launch builds.
#
######################################################################

buildZeromq() {
  if ! bilderUnpack zeromq; then
    return 1
  fi
  local otherargsvar=`genbashvar ZEROMQ_${ZEROMQ_BUILD}`_OTHER_ARGS
  local zmqotherargs=`deref ${otherargsvar}`
  if bilderConfig zeromq $ZEROMQ_BUILD "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $zmqotherargs"; then
    bilderBuild zeromq $ZEROMQ_BUILD
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


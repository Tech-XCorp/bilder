#!/bin/bash
#
# Version and build information for openssl
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

OPENSSL_BLDRVERSION_STD=${OPENSSL_BLDRVERSION_STD:-"1.0.1c"}
OPENSSL_BLDRVERSION_EXP=${OPENSSL_BLDRVERSION_EXP:-"1.0.1c"}

######################################################################
#
# Builds, deps, mask, auxdata, paths
#
######################################################################

OPENSSL_BUILDS=${OPENSSL_BUILDS:-"NONE"}
OPENSSL_DEPS=

######################################################################
#
# Launch openssl builds.
#
######################################################################

buildOpenSsl() {
  if ! bilderUnpack -i openssl; then
    return
  fi
  OPENSSL_OTHER_ARGS=`deref OPENSSL_${FORPYTHON_BUILD}_OTHER_ARGS`
# Tested for Linux only.  Builds shared and static.  Automatically picks gcc.
# Want ./config --prefix=$CONTRIB_DIR/openssl-1.0.1c --openssldir=$CONTRIB_DIR/openssl-1.0.1c shared
  if bilderConfig -i -C config openssl $FORPYTHON_BUILD "--prefix=$CONTRIB_DIR/openssl-${OPENSSL_BLDRVERSION}-${FORPYTHON_BUILD} --openssldir=$CONTRIB_DIR/openssl-${OPENSSL_BLDRVERSION}-${FORPYTHON_BUILD} shared $OPENSSL_OTHER_ARGS"; then
    bilderBuild openssl $FORPYTHON_BUILD
  fi
}

######################################################################
#
# Test openssl
#
######################################################################

testOpenSsl() {
  techo "Not testing openssl."
}

######################################################################
#
# Install openssl
#
######################################################################

installOpenSsl() {
# Ignore installation errors.
  bilderInstall -p open openssl $FORPYTHON_BUILD
# Link executable into bin
  cmd="ln -sf $CONTRIB_DIR/openssl-${OPENSSL_BLDRVERSION}-$FORPYTHON_BUILD/bin/openssl $CONTRIB_DIR/bin/openssl"
  techo "$cmd"
  $cmd
}


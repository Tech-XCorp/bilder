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
  if bilderUnpack -i openssl; then
# Want ./config --prefix=$CONTRIB_DIR/openssl-1.0.1c --openssldir=$CONTRIB_DIR/openssl-1.0.1c
    if bilderConfig -i -m config openssl $FORPYTHON_BUILD "--prefix=$CONTRIB_DIR/openssl-$OPENSSL_BLDRVERSION --openssldir=$CONTRIB_DIR/openssl-$OPENSSL_BLDRVERSION"; then
      bilderBuild openssl $FORPYTHON_BUILD
    fi
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
  cmd="ln -s $CONTRIB_DIR/openssl-$OPENSSL_BLDRVERSION/bin/openssl $CONTRIB_DIR/bin/openssl"
  techo "$cmd"
  $cmd
}


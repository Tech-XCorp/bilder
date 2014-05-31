#!/bin/bash
#
# Build information for openssl
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in openssl_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/openssl_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOpensslNonTriggerVars() {
  :
}
setOpensslNonTriggerVars

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


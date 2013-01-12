#!/bin/bash
#
# Version and build information for txssh
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

TXSSH_BLDRVERSION=${TXSSH_BLDRVERSION:-""}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$TXSSH_DESIRED_BUILDS"; then
  TXSSH_DESIRED_BUILDS=ser,sersh
fi
computeBuilds txssh
addCc4pyBuild txssh
TXSSH_DEPS=${TXSSH_DEPS:-"cmake,libssh,boost,ne7ssh"}
TXSSH_UMASK=007

######################################################################
#
# Launch txssh builds
#
######################################################################

buildTxssh() {

  getVersion txssh

# Standard sequence
  if bilderPreconfig -c txssh; then
    if bilderConfig txssh ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $REPO_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $TXSSH_SER_OTHER_ARGS"; then
      bilderBuild txssh ser
    fi
    if bilderConfig txssh sersh "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DUSE_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $REPO_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $TXSSH_SERSH_OTHER_ARGS"; then
      bilderBuild txssh sersh
    fi
    if bilderConfig txssh cc4py "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DUSE_CC4PY_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $REPO_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $TXSSH_PYC_OTHER_ARGS"; then
      bilderBuild txssh cc4py
    fi
  fi

}

######################################################################
#
# Test txssh must be driven from top level qdstests
#
######################################################################

testTxssh() {
  techo "Not testing txssh. Driven from top level qdstests."
}


######################################################################
#
# Install txssh
#
######################################################################

installTxssh() {
  for bld in `echo $TXSSH_BUILDS | tr ',' ' '`; do
    bilderInstall txssh $bld
  done
}


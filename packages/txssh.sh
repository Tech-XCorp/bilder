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
  TXSSH_DESIRED_BUILDS=ser
  case `uname` in
    CYGWIN*) TXSSH_DESIRED_BUILDS=${TXSSH_DESIRED_BUILDS},sersh;;
  esac
fi
computeBuilds txssh
if ! [[ `uname` =~ CYGWIN ]]; then
  addCc4pyBuild txssh
fi
TXSSH_DEPS=${TXSSH_DEPS:-"cmake,botan,ne7ssh"}
TXSSH_UMASK=007

######################################################################
#
# Launch txssh builds
#
######################################################################

buildTxssh() {

  getVersion txssh

# On windows, we configure with shared library support to match Qt
# (this gives us the /MD compile option instead of /MT)
  local SHARED_LIBS_FLAG=""
  case `uname` in
    CYGWIN*)
    SHARED_LIBS_FLAG="-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE"
    ;;
  esac

  case `uname` in
    CYGWIN*)
      TXSSH_COMPILERS="$CMAKE_COMPILERS_SER"
      TXSSH_COMPILER_FLAGS="$CMAKE_COMPFLAGS_SER"
      ;;
    *)
      TXSSH_COMPILERS="$CMAKE_COMPILERS_PYC"
      TXSSH_COMPILER_FLAGS="$CMAKE_COMPFLAGS_PYC"
      ;;
  esac

# Standard sequence
  if bilderPreconfig -c txssh; then
    if bilderConfig txssh ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $TXSSH_SER_OTHER_ARGS"; then
      bilderBuild txssh ser
    fi
    if bilderConfig txssh sersh "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $TXSSH_SERSH_OTHER_ARGS"; then
      bilderBuild txssh sersh
    fi
    if bilderConfig txssh cc4py "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_NODEFLIB_FLAGS $CMAKE_SUPRA_SP_ARG $TXSSH_PYC_OTHER_ARGS"; then
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
  bilderInstall txssh ser
  bilderInstall txssh sersh
  bilderInstall txssh cc4py
}


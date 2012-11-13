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

# Built from package only
######################################################################
#
# Other values
#
######################################################################

TXSSH_BUILDS=${TXSSH_BUILDS:-"ser"}
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
    if bilderConfig -c txssh ser "$TXSSH_COMPILERS $TXSSH_COMPILER_FLAGS $SHARED_LIBS_FLAG $CMAKE_SUPRA_SP_ARG $TXSSH_SER_OTHER_ARGS"; then
      bilderBuild txssh ser
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
}


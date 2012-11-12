#!/bin/bash
#
# Version and build information for txphysics
#
# $Id: txphysics.sh 5979 2012-05-07 12:51:48Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Other values
#
######################################################################

# Not doing sersh build on any platform, as taken care of by
# txphysics build system (for Linux and Mac)
TXPHYSICS_BUILDS=${TXPHYSICS_BUILDS:-"ser"}
addBenBuild txphysics
TXPHYSICS_DEPS=cmake

######################################################################
#
# Launch txphysics builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildTxphysics() {

# Revert if needed and get version
  getVersion txphysics

# Args on AIX.  The configure system should deal with this.
  case `uname` in
    AIX)
      TXPHYSICS_MAKE_ARGS=${TXPHYSICS_MAKE_ARGS:-"TAR=gtar"}
      ;;
  esac

# Remove /MD flag
  local TXPHYSICS_SER_ADDL_ARGS="$CMAKE_NODEFLIB_FLAGS"
  local TXPHYSICS_BEN_ADDL_ARGS="$CMAKE_NODEFLIB_FLAGS"

# Build serial.  Eliminate definition of lib flags
  if bilderPreconfig -c txphysics; then
    if bilderConfig -c txphysics ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TXPHYSICS_SER_OTHER_ARGS $TXPHYSICS_SER_ADDL_ARGS"; then
      bilderBuild txphysics ser "$TXPHYSICS_MAKE_ARGS"
    fi
# Serial-shared, libflags are defined
    if bilderConfig -c -p txphysics-${TXPHYSICS_BLDRVERSION}-ser txphysics sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED_LIBS:BOOL=ON $TXPHYSICS_SERSH_OTHER_ARGS"; then
    # if bilderConfig -c txphysics sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED_LIBS:BOOL=ON $TXPHYSICS_SERSH_OTHER_ARGS"; then
      bilderBuild txphysics sersh "$TXPHYSICS_MAKE_ARGS"
    fi
# Build gcc.  Eliminate definition of lib flags
    if bilderConfig -c txphysics ben "$CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $TXPHYSICS_BEN_OTHER_ARGS $TXPHYSICS_BEN_ADDL_ARGS"; then
      bilderBuild txphysics ben "$TXPHYSICS_MAKE_ARGS"
    fi
  fi

}

######################################################################
#
# Test txphysics
#
######################################################################

testTxphysics() {
  techo "Not testing txphysics."
}

######################################################################
#
# Install txphysics
#
######################################################################

installTxphysics() {
# For the first installation into the same area, it is okay to remove
# the previous installation.
  bilderInstall -r txphysics ser
  bilderInstall txphysics sersh
  bilderInstall txphysics ben
}


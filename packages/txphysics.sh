#!/bin/bash
#
# Version and build information for txphysics
#
# $Id$
#
######################################################################

######################################################################
#
# Version.  No current tarball, so always build from repo.
#
######################################################################

# Built from svn repo only

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setTxPhysicsGlobalVars() {
# txphysics used only by engine, so no sersh build needed
  TXPHYSICS_BUILDS=${TXPHYSICS_BUILDS:-"ser"}
  computeBuilds txphysics
  addBenBuild txphysics
  TXPHYSICS_DEPS=cmake
# txphysics does not have ctesting.  Uncomment when it does.
  # $TESTING_BUILDS && TXPHYSICS_CTEST_TARGET=${TXPHYSICS_CTEST_TARGET:-"$BILDER_CTEST_TARGET"}
}
setTxPhysicsGlobalVars

######################################################################
#
# Launch txphysics builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildTxphysics() {

# Revert if needed and get version
  getVersion txphysics
  if ! bilderPreconfig -c txphysics; then
    return
  fi

# Use make -j, always set up submitting
  local TXPHYSICS_MAKE_ARGS=
# txphysics does not have develdocs.  Uncomment when that happens.
  # local TXPHYSICS_DEVELDOCS_MAKE_ARGS=apidocs-force
  if test -n "$TXPHYSICS_CTEST_TARGET"; then
    TXPHYSICS_MAKE_ARGS="$TXPHYSICS_MAKE_ARGS ${TXPHYSICS_CTEST_TARGET}Start ${TXPHYSICS_CTEST_TARGET}Build"
    # TXPHYSICS_DEVELDOCS_MAKE_ARGS="$TXPHYSICS_MAKE_ARGS"
  fi

# Build serial.  Eliminate definition of lib flags
  if bilderConfig -c txphysics ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TXPHYSICS_SER_OTHER_ARGS"; then
    bilderBuild txphysics ser "$TXPHYSICS_MAKE_ARGS"
  fi
# Build serial-shared.  Install with serial.
  if bilderConfig -c -p txphysics-${TXPHYSICS_BLDRVERSION}-ser txphysics sersh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TXPHYSICS_SERSH_OTHER_ARGS"; then
    bilderBuild txphysics sersh "$TXPHYSICS_MAKE_ARGS"
  fi
# Build ben
  if bilderConfig -c txphysics ben "$CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $TXPHYSICS_BEN_OTHER_ARGS"; then
    bilderBuild txphysics ben "$TXPHYSICS_MAKE_ARGS"
  fi

}

######################################################################
#
# Test txphysics
#
######################################################################

testTxphysics() {
# Not doing much here, as neither testing builds nor submitting, but
# ready for when txphysics is ready by uncommenting upper line and
# removing lower.
  bilderRunTests -i ben txphysics "" "${TXPHYSICS_CTEST_TARGET}Test"
}

######################################################################
#
# Install txphysics
#
######################################################################

installTxphysics() {
# Prepared for when txphysics has develdocs
  TXPHYSICS_DEVELDOCS_INSTALL_TARGET=install-apidocs
  bilderInstallTestedPkg -i ben txphysics "" " -p open"
}


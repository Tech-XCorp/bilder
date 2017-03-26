#!/bin/sh
######################################################################
#
# @file    txphysics.sh
#
# @brief   Build information for txphysics.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in txphysics_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/txphysics_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTxphysicsNonTriggerVars() {
  TXPHYSICS_MASK=002
# This allows individual package control of testing
  TXPHYSICS_TESTING=${TXPHYSICS_TESTING:-"${TESTING}"}
# This allows individual package control over whether ctest is used
  TXPHYSICS_USE_CTEST=${TXPHYSICS_USE_CTEST:-"$BILDER_USE_CTEST"}
# This allows individual package control over ctest submission model
  TXPHYSICS_CTEST_MODEL=${TXPHYSICS_CTEST_MODEL:-"$BILDER_CTEST_MODEL"}
}
setTxphysicsNonTriggerVars

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
  if $TXPHYSICS_USE_CTEST; then
    TXPHYSICS_MAKE_ARGS="$TXPHYSICS_MAKE_ARGS ${TXPHYSICS_CTEST_MODEL}Build"
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
  local perbuildarg=
  $TXPHYSICS_TESTING && perbuildarg=-b
  local testtarg=test
  $TXPHYSICS_USE_CTEST && testtarg="${TXPHYSICS_CTEST_MODEL}Test"
  bilderRunTests ${perbuildarg} -s -i ben txphysics "" "${testtarg}"
}

######################################################################
#
# Install txphysics
#
######################################################################

installTxphysics() {
# Prepared for when txphysics has develdocs
  TXPHYSICS_DEVELDOCS_INSTALL_TARGET=install-apidocs
  bilderInstallTestedPkg -i ben -a "-r -p open" txphysics
}


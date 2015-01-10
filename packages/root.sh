#!/bin/bash
#
# Version and build information for root
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

ROOT_BLDRVERSION=${ROOT_BLDRVERSION:-"5.34.14"}

######################################################################
#
# Other values
#
######################################################################

setRootGlobalVars() {
  ROOT_BUILD=${ROOT_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  ROOT_BUILDS=${ROOT_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  ROOT_DEPS=cmake
}
setRootGlobalVars

######################################################################
#
# Launch root builds.
#
######################################################################

buildRoot() {
  if ! bilderUnpack root; then
    return
  fi
  if bilderConfig -c root $ROOT_BUILD "-Dgdml:BOOL=ON"; then
    bilderBuild root $ROOT_BUILD "$ROOT_MAKEJ_ARGS"
  fi
}

######################################################################
#
# Test root
#
######################################################################

testRoot() {
  techo "Not testing root."
}

######################################################################
#
# Install root
#
######################################################################

installRoot() {
  bilderInstallAll root
}


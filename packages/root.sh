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
  ROOT_BUILDS=${ROOT_BUILDS:-"ser"}
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
  if bilderConfig -c root ser "-Dgdml:BOOL=ON"; then
    bilderBuild root ser "" "$ROOT_MAKEJ_ARGS"
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
  bilderInstall root ser
}


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
  ROOT_BUILDS=${ROOT_BUILDS:-"sersh"}
  ROOT_DEPS=cmake
}
setRootGlobalVars

######################################################################
#
# Launch root builds.
#
######################################################################

buildRoot() {
  if ! bilderUnpack -c root; then
    return
  fi
  if bilderConfig -c root sersh "-Dgdml:BOOL=ON"; then
    bilderBuild root sersh "$ROOT_MAKEJ_ARGS"
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
  bilderInstall root sersh
}


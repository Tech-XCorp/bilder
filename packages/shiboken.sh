#!/bin/bash
#
# Version and build information for shiboken
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SHIBOKEN_BLDRVERSION=${SHIBOKEN_BLDRVERSION:-"1.2.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setShibokenGlobalVars() {
  SHIBOKEN_BUILDS=ser
  SHIBOKEN_DEPS=cmake,bzip2
  SHIBOKEN_UMASK=002
}
setShibokenGlobalVars

######################################################################
#
# Launch shiboken builds.
#
######################################################################

buildShiboken() {

# Get version, see about installing
  if ! bilderUnpack shiboken; then
    return
  fi

# configure and install
  if bilderConfig shiboken ser; then
    bilderBuild shiboken ser
  fi

}

######################################################################
#
# Test shiboken
#
######################################################################

testShiboken() {
  techo "Not testing shiboken."
}

######################################################################
#
# Install shiboken
#
######################################################################

installShiboken() {
  if bilderInstall shiboken ser; then
    ln -sf $CONTRIB_DIR/shiboken/bin/shiboken $CONTRIB_DIR/bin/shiboken
  fi
}


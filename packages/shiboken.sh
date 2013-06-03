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

SHIBOKEN_BLDRVERSION=${SHIBOKEN_BLDRVERSION:-"1.1.2"}

######################################################################
#
# Other values
#
######################################################################

SHIBOKEN_BUILDS=ser
SHIBOKEN_DEPS=cmake,bzip2
SHIBOKEN_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

# addtopathvar PATH $CONTRIB_DIR/shiboken/bin

######################################################################
#
# Launch shiboken builds.
#
######################################################################

buildShiboken() {
  if bilderUnpack shiboken; then
    if bilderConfig shiboken ser; then
      bilderBuild shiboken ser
    fi
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
    ln -sf $CONTRIB_DIR/shiboken-ser/bin/shiboken $CONTRIB_DIR/bin/shiboken
  fi
}


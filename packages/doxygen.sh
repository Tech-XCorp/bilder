#!/bin/bash
#
# Version and build information for doxygen
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

DOXYGEN_BLDRVERSION_STD=1.8.5
DOXYGEN_BLDRVERSION_EXP=1.8.5

######################################################################
#
# Builds, deps, mask, auxdata, paths
#
######################################################################

case `uname` in
  CYGWIN*) ;;
  *) DOXYGEN_BUILDS=${DOXYGEN_BUILDS:-"ser"};;
esac
DOXYGEN_DEPS=

######################################################################
#
# Launch doxygen builds.
#
######################################################################

buildDoxygen() {
  if bilderUnpack -i doxygen; then
    if bilderConfig -i -n -p - doxygen ser; then
      bilderBuild doxygen ser
    fi
  fi
}

######################################################################
#
# Test doxygen
#
######################################################################

testDoxygen() {
  techo "Not testing doxygen."
}

######################################################################
#
# Install doxygen
#
######################################################################

installDoxygen() {
# Ignore installation errors.  Doxygen tries to set perms of /contrib/bin.
  bilderInstall -p open doxygen ser "" "-i"
# Because doxygen mucks with perms, have to reset
  setOpenPerms $CONTRIB_DIR/bin
}


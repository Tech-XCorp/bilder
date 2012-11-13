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

case `uname`-`uname -r` in
  Darwin-11.*) DOXYGEN_BLDRVERSION=${DOXYGEN_BLDRVERSION:-"1.8.0"};;
  *) DOXYGEN_BLDRVERSION=${DOXYGEN_BLDRVERSION:-"1.8.1.1"};;
esac

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
  bilderInstall doxygen ser "" "-i"
}


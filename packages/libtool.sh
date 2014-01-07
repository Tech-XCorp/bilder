#!/bin/bash
#
# Version and build information for libtool
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

LIBTOOL_BLDRVERSION_STD=${LIBTOOL_BLDRVERSION_STD:-"2.4.2"}
LIBTOOL_BLDRVERSION_EXP=${LIBTOOL_BLDRVERSION_EXP:-"2.4.2"}
computeVersion libtool

######################################################################
#
# Other values
#
######################################################################

LIBTOOL_BUILDS=${LIBTOOL_BUILDS:-"ser"}
LIBTOOL_DEPS=automake,autoconf,m4
LIBTOOL_UMASK=002

######################################################################
#
# Launch libtool builds.
#
######################################################################

buildLibtool() {
  if bilderUnpack libtool; then
    if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION libtool ser; then
      bilderBuild -m make libtool ser
    fi
  fi
}

######################################################################
#
# Test libtool
#
######################################################################

testLibtool() {
  techo "Not testing libtool."
}

######################################################################
#
# Install libtool
#
######################################################################

installLibtool() {
  if which /usr/bin/install 1>/dev/null 2>&1; then
    bilderInstall -m make libtool ser autotools "INSTALL=/usr/bin/install"
  else
    bilderInstall -m make libtool ser autotools
  fi
  # techo "WARNING: Quitting at end of installLibtool."; cleanup
}


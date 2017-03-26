#!/bin/sh
######################################################################
#
# @file    shtool.sh
#
# @brief   Version and build information for shtool.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SHTOOL_BLDRVERSION=${SHTOOL_BLDRVERSION:-"2.0.8"}

######################################################################
#
# Other values
#
######################################################################

SHTOOL_BUILDS=${SHTOOL_BUILDS:-"ser"}
SHTOOL_DEPS=

######################################################################
#
# Launch shtool builds.
#
######################################################################

buildShtool() {
  if bilderUnpack $FORCE_AUTOBUILD shtool; then
    bilderConfig $FORCE_AUTOBUILD -p autotools-lt-$LIBTOOL_BLDRVERSION shtool ser
    bilderBuild -m make shtool ser
  fi
}

######################################################################
#
# Test shtool
#
######################################################################

testShtool() {
  techo "Not testing shtool."
}

######################################################################
#
# Install shtool
#
######################################################################

installShtool() {
  bilderInstall -m make shtool ser autotools
}


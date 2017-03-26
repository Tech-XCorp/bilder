#!/bin/sh
######################################################################
#
# @file    clhep.sh
#
# @brief   Version and build information for clhep.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

CLHEP_BLDRVERSION=${CLHEP_BLDRVERSION:-"2.0.4.5"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$CLHEP_BUILDS"; then
  CLHEP_BUILDS=ser
fi
CLHEP_DEPS=
CLHEP_UMASK=002

######################################################################
#
# Launch clhep builds.
#
######################################################################

buildClhep() {
  if bilderUnpack clhep; then
    if bilderConfig clhep ser; then
      bilderBuild -m make clhep ser
    fi
  fi
}

######################################################################
#
# Test clhep
#
######################################################################

testClhep() {
  techo "Not testing clhep."
}

######################################################################
#
# Install clhep
#
######################################################################

installClhep() {
  bilderInstall -m make clhep ser
}


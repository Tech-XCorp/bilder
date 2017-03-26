#!/bin/sh
######################################################################
#
# @file    arprec.sh
#
# @brief   Version and build information for arprec
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

ARPREC_BLDRVERSION=${ARPREC_BLDRVERSION:-"2.2.13"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$ARPREC_BUILDS"; then
  ARPREC_BUILDS=ser
fi

ARPREC_DEPS=autotools
ARPREC_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch arprec builds.
#
######################################################################

buildArprec() {
  if bilderUnpack arprec; then
    if bilderConfig arprec ser; then
      bilderBuild arprec ser
    fi
  fi
}

######################################################################
#
# Test arprec
#
######################################################################

testArprec() {
  techo "Not testing arprec."
}

######################################################################
#
# Install arprec
#
######################################################################

installArprec() {
  bilderInstall arprec ser
}

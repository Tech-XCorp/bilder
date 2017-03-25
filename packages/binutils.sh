#!/bin/sh
######################################################################
#
# @file    binutils.sh
#
# @brief   Version and build information for binutils
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

BINUTILS_BLDRVERSION=${BINUTILS_BLDRVERSION:-"2.22"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$BINUTILS_BUILDS"; then
  BINUTILS_BUILDS=ser
fi

BINUTILS_DEPS=autotools
BINUTILS_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch binutils builds.
#
######################################################################

buildBinutils() {
  if bilderUnpack binutils; then
    if bilderConfig binutils ser; then
      bilderBuild binutils ser
    fi
  fi
}

######################################################################
#
# Test binutils
#
######################################################################

testBinutils() {
  techo "Not testing binutils."
}

######################################################################
#
# Install binutils
#
######################################################################

installBinutils() {
  bilderInstall binutils ser
}

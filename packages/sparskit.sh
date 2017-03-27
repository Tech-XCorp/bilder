#!/bin/sh
######################################################################
#
# @file    sparskit.sh
#
# @brief   Version and build information for sparskit.
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

SPARSKIT_BLDRVERSION=${SPARSKIT_BLDRVERSION:-"2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$SPARSKIT_BUILDS"; then
  SPARSKIT_BUILDS=ser
fi
SPARSKIT_UMASK=002

######################################################################
#
# Launch sparskit builds.
#
######################################################################

buildSparskit() {
  if bilderUnpack -i sparskit; then
    if bilderConfig -C " " sparskit ser; then
      bilderBuild sparskit ser
    fi
  fi
}

######################################################################
#
# Test sparskit
#
######################################################################

testSparskit() {
  techo "Not testing sparskit."
}

######################################################################
#
# Install sparskit
#
######################################################################

installSparskit() {
  bilderInstall -c sparskit ser
}

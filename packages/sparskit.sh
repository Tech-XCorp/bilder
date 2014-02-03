#!/bin/bash
#
# Version and build information for sparskit
#
# $Id$
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

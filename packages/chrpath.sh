#!/bin/bash
#
# Version and build information for chrpath
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

CHRPATH_BLDRVERSION=${CHRPATH_BLDRVERSION:-"0.13"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

# Build only if not present
if test `uname` = Linux && ! which chrpath 1>/dev/null; then
  CHRPATH_BUILDS=${CHRPATH_BUILDS:-"ser"}
fi
CHRPATH_DEPS=
CHRPATH_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildChrpath() {
  if bilderUnpack chrpath; then
    if bilderConfig chrpath ser; then
      bilderBuild chrpath ser
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testChrpath() {
  techo "Not testing chrpath."
}

######################################################################
#
# Install
#
######################################################################

installChrpath() {
  if bilderInstall chrpath ser; then
    mkdir -p $CONTRIB_DIR/bin
    (cd $CONTRIB_DIR/bin; ln -sf ../chrpath/bin/chrpath .)
  fi
}


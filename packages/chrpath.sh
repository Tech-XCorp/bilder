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
# Other values
#
######################################################################

# Build only if not present
case `uname` in
  Linux)
    if which chrpath 1>/dev/null; then
      : # techo "chrpath = "`which chrpath`
    else
      # techo "WARNING: chrpath not found.  Will build."
      CHRPATH_BUILDS=${CHRPATH_BUILDS:-"ser"}
    fi
    ;;
esac
# techo "CHRPATH_BUILDS = $CHRPATH_BUILDS."
CHRPATH_DEPS=

######################################################################
#
# Launch chrpath builds.
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
# Test chrpath
#
######################################################################

testChrpath() {
  techo "Not testing chrpath."
}

######################################################################
#
# Install chrpath
#
######################################################################

installChrpath() {
  if bilderInstall chrpath ser; then
    mkdir -p $CONTRIB_DIR/bin
    (cd $CONTRIB_DIR/bin; ln -sf ../chrpath/bin/chrpath .)
  fi
}


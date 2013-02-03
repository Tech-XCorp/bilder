#!/bin/bash
#
# Version and build information for uncrustify
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

UNCRUSTIFY_BLDRVERSION=${UNCRUSTIFY_BLDRVERSION:-"0.60"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

case `uname` in
  CYGWIN) ;;
  *) UNCRUSTIFY_BUILDS=${UNCRUSTIFY_BUILDS:-"ser"};;
esac
UNCRUSTIFY_DEPS=
UNCRUSTIFY_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildUncrustify() {
  if bilderUnpack uncrustify; then
    if bilderConfig uncrustify ser; then
      bilderBuild uncrustify ser
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testUncrustify() {
  techo "Not testing uncrustify."
}

######################################################################
#
# Install
#
######################################################################

installUncrustify() {
  if bilderInstall uncrustify ser; then
    mkdir -p $CONTRIB_DIR/bin
    (cd $CONTRIB_DIR/bin; ln -sf ../uncrustify/bin/uncrustify .)
  fi
}


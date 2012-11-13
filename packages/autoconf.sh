#!/bin/bash
#
# Version and build information for autoconf
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

AUTOCONF_BLDRVERSION_STD=2.69
AUTOCONF_BLDRVERSION_EXP=2.69

######################################################################
#
# Other values
#
######################################################################

AUTOCONF_BUILDS=${AUTOCONF_BUILDS:-"ser"}
AUTOCONF_DEPS=m4,xz
AUTOCONF_UMASK=002

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/autotools/bin

######################################################################
#
# Launch autoconf builds.
#
######################################################################

buildAutoconf() {
# Libtool determines the installation prefix
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
# If executable not found, under prefix, needs installing
  if ! test -x $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/autoconf; then
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR autoconf,ser
  fi
# Build
  if bilderUnpack autoconf; then
    if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION autoconf ser; then
      bilderBuild -m make autoconf ser
    fi
  fi
}

######################################################################
#
# Test autoconf
#
######################################################################

testAutoconf() {
  techo "Not testing autoconf."
}

######################################################################
#
# Install autoconf
#
######################################################################

installAutoconf() {
  bilderInstall -m make autoconf ser autotools
  # techo "Quitting at end of installAutoconf."; exit
}


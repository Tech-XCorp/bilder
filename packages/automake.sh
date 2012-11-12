#!/bin/bash
#
# Version and build information for automake
#
# $Id: automake.sh 6607 2012-09-05 13:43:44Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

AUTOMAKE_BLDRVERSION_STD=1.12.1
AUTOMAKE_BLDRVERSION_EXP=1.12.1

######################################################################
#
# Other values
#
######################################################################

AUTOMAKE_BUILDS=${AUTOMAKE_BUILDS:-"ser"}
AUTOMAKE_DEPS=autoconf
AUTOMAKE_UMASK=002

######################################################################
#
# Launch automake builds.
#
######################################################################

buildAutomake() {
# Libtool determines the installation prefix
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
# If executable not found, under prefix, needs installing
  if ! test -x $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/automake; then
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR automake,ser
  fi
# Build
  if bilderUnpack automake; then
    if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION automake ser; then
      bilderBuild -m make automake ser
    fi
  fi
}

######################################################################
#
# Test automake
#
######################################################################

testAutomake() {
  techo "Not testing automake."
}

######################################################################
#
# Install automake
#
######################################################################

installAutomake() {
  bilderInstall -m make automake ser autotools
}


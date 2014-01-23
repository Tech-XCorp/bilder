#!/bin/bash
#
# Version and build information for automake
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Fedora 20 has to have old automake
if test -f /etc/redhat-release; then
  fcnum=`sed -e 's/Fedora release *//' -e 's/ .*$//' </etc/redhat-release`
  if test $fcnum -ge 20; then
    AUTOMAKE_BLDRVERSION=${AUTOMAKE_BLDRVERSION:-"1.13.4"}
  fi
fi
AUTOMAKE_BLDRVERSION_STD=${AUTOMAKE_BLDRVERSION_STD:-"1.14"}
AUTOMAKE_BLDRVERSION_EXP=${AUTOMAKE_BLDRVERSION_EXP:-"1.13.4"}

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


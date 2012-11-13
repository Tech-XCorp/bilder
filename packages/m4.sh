#!/bin/bash
#
# Version and build information for m4
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

M4_BLDRVERSION=${M4_BLDRVERSION:-"1.4.16"}

######################################################################
#
# Other values
#
######################################################################

M4_BUILDS=${M4_BUILDS:-"ser"}
M4_DEPS=
M4_UMASK=002

######################################################################
#
# Launch m4 builds.
#
######################################################################

buildM4() {
# Libtool determines the installation prefix
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
# If executable not found, under prefix, needs installing
  if ! test -x $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/m4; then
    techo "Executable, $CONTRIB_DIR/autotools-lt-$LIBTOOL_BLDRVERSION/bin/m4, not found."
    $BILDER_DIR/setinstald.sh -r -i $CONTRIB_DIR m4,ser
  fi
# On to the regular build
  if bilderUnpack m4; then
    if bilderConfig -p autotools-lt-$LIBTOOL_BLDRVERSION m4 ser; then
      bilderBuild -m make m4 ser
    fi
  fi
}

######################################################################
#
# Test m4
#
######################################################################

testM4() {
  techo "Not testing m4."
}

######################################################################
#
# Install m4
#
######################################################################

installM4() {
  bilderInstall -m make m4 ser autotools
  # techo "WARNING: exit in $BASH_SOURCE"; exit
}


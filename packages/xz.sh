#!/bin/bash
#
# Version and build information for xz
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

XZ_BLDRVERSION=${XZ_BLDRVERSION:-"5.0.3"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$XZ_BUILDS"; then
  # if ! [[ `uname` =~ CYGWIN ]]; then
    XZ_BUILDS=ser
  # fi
fi
XZ_DEPS=doxygen
XZ_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

techo -2 "Adding $CONTRIB_DIR/xz/bin to PATH."
addtopathvar PATH $CONTRIB_DIR/xz/bin
techo -2 "PATH = $PATH."

######################################################################
#
# Launch xz builds.
#
######################################################################

buildXz() {
  techo
# Configure and build
  if bilderUnpack xz; then
    if bilderConfig xz ser "" "" CC=gcc; then
      bilderBuild -m make xz ser "" "CC=gcc LD_RUN_PATH=$CONTRIB_DIR/xz-${XZ_BLDRVERSION}-ser/lib"
    fi
  fi
}

######################################################################
#
# Test xz
#
######################################################################

testXz() {
  techo "Not testing xz."
}

######################################################################
#
# Install xz
#
######################################################################

installXz() {
  bilderInstall xz ser
  # techo "WARNING: Quitting at end of installXz."; cleanup
}


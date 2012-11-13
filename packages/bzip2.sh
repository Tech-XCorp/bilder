#!/bin/bash
#
# Version and build information for bzip2
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

BZIP2_BLDRVERSION=${BZIP2_BLDRVERSION:-"1.0.6"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$BZIP2_BUILDS"; then
  if [[ `uname` =~ CYGWIN ]]; then
    BZIP2_BUILDS=ser
  fi
fi
BZIP2_DEPS=
BZIP2_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/bzip2/bin

######################################################################
#
# Launch bzip2 builds.
#
######################################################################

buildBzip2() {
  techo
# Configure and build
  if [[ `uname` =~ CYGWIN ]]; then
    BZIP2_MAKE_ARGS="-f makefile.msc"
  fi
  if bilderUnpack -i bzip2; then
# No configure system
    BZIP2_CONFIG_METHOD=none
    BZIP2_SER_INSTALL_DIR=$CONTRIB_DIR
    BZIP2_SER_BUILD_DIR=$BUILD_DIR/bzip2-$BZIP2_BLDRVERSION/ser
    bilderBuild bzip2 ser "$BZIP2_MAKE_ARGS"
  fi
}

######################################################################
#
# Test bzip2
#
######################################################################

testBzip2() {
  techo "Not testing bzip2."
}

######################################################################
#
# Install bzip2
#
######################################################################

installBzip2() {
  BZIP2_SER_INSTALL_SUBDIR=bzip2-$BZIP2_BLDRVERSION-ser
  local PREFIX=$CONTRIB_DIR/$BZIP2_SER_INSTALL_SUBDIR
  if [[ `uname` =~ CYGWIN ]]; then
    PREFIX=`cygpath -aw $PREFIX`
  fi
  bilderInstall bzip2 ser bzip2 "$BZIP2_MAKE_ARGS PREFIX='$PREFIX'"
  # techo "WARNING: Quitting at the end of bzip2.sh."; cleanup
}


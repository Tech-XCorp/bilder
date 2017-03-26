#!/bin/sh
######################################################################
#
# @file    bzip2.sh
#
# @brief   Build information for bzip2.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in bzip2_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/bzip2_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setBzip2NonTriggerVars() {
  BZIP2_UMASK=002
}
setBzip2NonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildBzip2() {
# Configure and build
  if [[ `uname` =~ CYGWIN ]]; then
    BZIP2_MAKE_ARGS="-f makefile.msc"
  fi
# bzip2 has no build/configure system
  BZIP2_CONFIG_METHOD=none
# Next line may not be needed.  Will test at work.
  BZIP2_SER_INSTALL_DIR=$CONTRIB_DIR
  if bilderUnpack -i bzip2; then
    BZIP2_SER_BUILD_DIR=$BUILD_DIR/bzip2-$BZIP2_BLDRVERSION/ser
    bilderBuild bzip2 ser "$BZIP2_MAKE_ARGS"
  fi
}

######################################################################
#
# Test
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
}


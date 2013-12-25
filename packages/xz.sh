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

XZ_BLDRVERSION_STD=${XZ_BLDRVERSION_STD:-"5.0.3"}
XZ_BLDRVERSION_EXP=${XZ_BLDRVERSION_EXP:-"5.0.3"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

XZ_BUILDS=${XZ_BUILDS:-"ser"}
XZ_DEPS=doxygen
XZ_UMASK=002
addtopathvar PATH $CONTRIB_DIR/xz/bin

######################################################################
#
# Launch builds
#
######################################################################

buildXz() {
# Configure and build
  if bilderUnpack xz; then
    if bilderConfig xz ser "" "" CC=gcc; then
      bilderBuild -m make xz ser "" "CC=gcc LD_RUN_PATH=$CONTRIB_DIR/xz-${XZ_BLDRVERSION}-ser/lib"
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testXz() {
  techo "Not testing xz."
}

######################################################################
#
# Install
#
######################################################################

installXz() {
  bilderInstall xz ser
}


#!/bin/bash
#
# Version and build information for pygments
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYGMENTS_BLDRVERSION=${PYGMENTS_BLDRVERSION:-"1.3.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

PYGMENTS_BUILDS=${PYGMENTS_BUILDS:-"cc4py"}
PYGMENTS_DEPS=setuptools,Python
PYGMENTS_UMASK=002

#####################################################################
#
# Launch builds.
#
######################################################################

buildPygments() {
  if bilderUnpack Pygments; then
    bilderDuBuild -p pygments Pygments "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testPygments() {
  techo "Not testing Pygments."
}

######################################################################
#
# Install
#
######################################################################

installPygments() {
  bilderDuInstall -r Pygments -p pygments Pygments "" "$DISTUTILS_ENV"
}


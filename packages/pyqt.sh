#!/bin/bash
#
# Build and installation of pyqt
#
# $Id$
#
########################################################################

########################################################################
#
# Version
#
########################################################################

case $(uname) in
  CYGWIN*) PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-"win-gpl-4.9.5"};;
  Darwin) PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-"mac-gpl-4.9.1"};;
  *) PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-"x11-gpl-4.9.1"};;
esac

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

PYQT_BUILDS=${PYQT_BUILDS:-"cc4py"}
PYQT_DEPS=qt,sip,Python
PYQT_UMASK=002

######################################################################
#
# Launch builds
#
######################################################################

buildPyQt() {

# Unpack
  if bilderUnpack PyQt; then
# Configure args: qmake must be found from path
    PYQT_CONFIG_ARGS="--confirm-license"
# Configure
    if bilderConfig -r PyQt cc4py "$PYQT_CONFIG_ARGS"; then
# Build
      bilderBuild PyQt cc4py
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testPyQt() {
  techo "Not testing pyqt."
}

######################################################################
#
# Install
#
######################################################################

installPyQt() {
  bilderInstall -r PyQt PyQt cc4py
}


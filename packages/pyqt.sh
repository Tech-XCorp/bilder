#!/bin/sh
######################################################################
#
# @file    pyqt.sh
#
# @brief   Version and build information for pyqt.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

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

if test -z "$PYQT_BUILDS"; then
  if [[ $(uname) =~ CYGWIN ]]; then
# PyQt does not build on windows due to crash of sip.
    PYQT_BUILDS=NONE
  else
    PYQT_BUILDS=pycsh
  fi
fi
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
    if bilderConfig -r PyQt pycsh "$PYQT_CONFIG_ARGS"; then
# Build
      bilderBuild PyQt pycsh
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
  bilderInstall -L -r PyQt pycsh
}


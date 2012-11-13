#!/bin/bash

########################################################################
#
# Automate the build of PyQt4
#
# @version $Id$
#
########################################################################

# ======================================================================
# Set the version and platform, since there are different tarballs for
# different platforms
# ======================================================================

case $(uname) in
  Darwin) PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-"mac-gpl-4.9.1"};;
# Nothing yet for Windows...
  *) PYQT_BLDRVERSION=${PYQT_BLDRVERSION:-"x11-gpl-4.9.1"};;
esac

# ======================================================================
# Set build and dependency parameters
# ======================================================================

PYQT_BUILDS=${PYQT_BUILDS:-"cc4py"}
PYQT_DEPS=qt,sip,Python

# ======================================================================
# Launch builds
# ======================================================================

buildPyQt() {

# Unpack
  if bilderUnpack PyQt; then
    techo "Running bilderDuBuild for PyQt."

# Remove old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/PyQt*"
    techo "$cmd"
    $cmd

# Configure
    PYQT_ARGS="-q $QT_BINDIR/qmake --confirm-license"
    if bilderConfig -r PyQt cc4py "$PYQT_ARGS"; then
# Build
      bilderBuild PyQt cc4py
    fi
  fi
}

# ======================================================================
# Test PyQt
# ======================================================================

testPyQt() {
  techo "Not testing pyqt."
}

# ======================================================================
# Install PyQt
# ======================================================================

installPyQt() {
  bilderInstall -L PyQt cc4py
}

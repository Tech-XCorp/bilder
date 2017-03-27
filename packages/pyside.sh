#!/bin/sh
######################################################################
#
# @file    pyside.sh
#
# @brief   Build information for pyside.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in pyside_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pyside_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPySideNonTriggerVars() {
  PYSIDE_UMASK=002
}
setPySideNonTriggerVars

######################################################################
#
# Launch pyside builds.
#
######################################################################

buildPySide() {

  if ! bilderUnpack PySide; then
    return 1
  fi

# Build
  bilderDuBuild -p pyside PySide "" "$DISTUTILS_ENV"

}

######################################################################
#
# Test pyside
#
######################################################################

testPySide() {
  techo "Not testing pyside."
}

######################################################################
#
# Install pyside
#
######################################################################

installPySide() {
  local PYSIDE_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/pyside.files'"
  bilderDuInstall -r PySide -p pyside PySide "$PYSIDE_INSTALL_ARGS" "$DISTUTILS_ENV"
}


#!/bin/sh
######################################################################
#
# @file    shiboken.sh
#
# @brief   Build information for shiboken.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in shiboken_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/shiboken_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setShibokenNonTriggerVars() {
  SHIBOKEN_UMASK=002
}
setShibokenNonTriggerVars

######################################################################
#
# Launch shiboken builds.
#
######################################################################

buildShiboken() {

# Get version, see about installing
  if ! bilderUnpack Shiboken; then
    return
  fi

# Build
  bilderDuBuild -p shiboken Shiboken "" "$DISTUTILS_ENV"

}

######################################################################
#
# Test shiboken
#
######################################################################

testShiboken() {
  techo "Not testing shiboken."
}

######################################################################
#
# Install shiboken
#
######################################################################

installShiboken() {
  local SHIBOKEN_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/shiboken.files'"
  bilderDuInstall -r Shiboken -p shiboken Shiboken "$SHIBOKEN_INSTALL_ARGS" "$DISTUTILS_ENV"
}


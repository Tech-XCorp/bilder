#!/bin/sh
######################################################################
#
# @file    babel.sh
#
# @brief   Build information for babel.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in babel_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/babel_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setDocutilsNonTriggerVars() {
  BABEL_UMASK=002
}
setDocutilsNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildBabel() {
  if bilderUnpack Babel; then
    bilderDuBuild -p babel Babel "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testBabel() {
  techo "Not testing Babel."
}

######################################################################
#
# Install
#
######################################################################

installBabel() {
  local BABEL_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/babel.files'"
  bilderDuInstall -p babel Babel "$BABEL_INSTALL_ARGS" "$DISTUTILS_ENV"
}


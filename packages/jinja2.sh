#!/bin/sh
######################################################################
#
# @file    jinja2.sh
#
# @brief   Build information for jinja2.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in jinja2_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/jinja2_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setDocutilsNonTriggerVars() {
  JINJA2_UMASK=002
}
setDocutilsNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildJinja2() {
  if bilderUnpack Jinja2; then
    bilderDuBuild -p jinja2 Jinja2 "" "$DISTUTILS_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testJinja2() {
  techo "Not testing Jinja2."
}

######################################################################
#
# Install
#
######################################################################

installJinja2() {
  local JINJA2_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/jinja2.files'"
  bilderDuInstall -r Jinja2 -p jinja2 Jinja2 "$JINJA2_INSTALL_ARGS" "$DISTUTILS_ENV"
}


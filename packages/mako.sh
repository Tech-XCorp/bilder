#!/bin/sh
######################################################################
#
# @file    mako.sh
#
# @brief   Build information for mako.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in mako_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/mako_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMakoNonTriggerVars() {
  MAKO_UMASK=002
}
setMakoNonTriggerVars

#####################################################################
#
# Launch mako builds.
#
######################################################################

buildMako() {
  if ! bilderUnpack Mako; then
    return
  fi
# Remove eggs as Bilder manages
  cmd="rm -rf ${PYTHON_SITEPKGSDIR}/Mako*.egg"
  techo -2 "$cmd"
  $cmd
# Build away
  MAKO_ENV="$DISTUTILS_ENV"
  techo -2 MAKO_ENV = $MAKO_ENV
  bilderDuBuild -p mako Mako '-' "$MAKO_ENV"
}

######################################################################
#
# Test mako
#
######################################################################

testMako() {
  techo "Not testing Mako."
}

######################################################################
#
# Install mako
#
######################################################################

installMako() {
  local MAKO_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/mako.files'"
  bilderDuInstall -p mako Mako "$MAKO_INSTALL_ARGS" "$MAKO_ENV"
  # bilderDuInstall -p mako Mako "--install-purelib=$PYTHON_SITEPKGSDIR" "$MAKO_ENV"
}

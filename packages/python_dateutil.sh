#!/bin/bash
#
# Build information for python_dateutil
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in python_dateutil_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/python_dateutil_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPython_dateutilNonTriggerVars() {
  PYTHON_DATEUTIL_UMASK=002
}
setPython_dateutilNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildPython_dateutil() {
  if ! bilderUnpack python_dateutil; then
    return
  fi
# Remove eggs and pth as Bilder manages
  cmd="rm -rf ${PYTHON_SITEPKGSDIR}/python_dateutil*.{egg,pth}"
  techo -2 "$cmd"
  $cmd
# Build
  bilderDuBuild -p dateutil python_dateutil "" "$DISTUTILS_ENV"
}

######################################################################
#
# Test
#
######################################################################

testPython_dateutil() {
  techo "Not testing Python_dateutil."
}

######################################################################
#
# Install
#
######################################################################

installPython_dateutil() {
  local PYTHON_DATEUTIL_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/dateutil.filelist'"
  bilderDuInstall -p dateutil python_dateutil "$PYTHON_DATEUTIL_INSTALL_ARGS" "$DISTUTILS_ENV"
}


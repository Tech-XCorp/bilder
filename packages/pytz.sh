#!/bin/bash
#
# Build information for pytz
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in pytz_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pytz_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPytzNonTriggerVars() {
  PYTZ_UMASK=002
}
setPytzNonTriggerVars

#####################################################################
#
# Build pytz
#
######################################################################

buildPytz() {
# Check for build need
  if ! bilderUnpack pytz; then
    return 1
  fi
# Remove eggs and pth as Bilder manages
  cmd="rm -rf ${PYTHON_SITEPKGSDIR}/pytz*.{egg,pth}"
  techo -2 "$cmd"
  $cmd
# Build away
  PYTZ_ENV="$DISTUTILS_ENV"
  techo -2 PYTZ_ENV = $PYTZ_ENV
  bilderDuBuild pytz "" "$PYTZ_ENV"
}

######################################################################
#
# Test pytz
#
######################################################################

testPytz() {
  techo "Not testing pytz."
}

######################################################################
#
# Install pytz
#
######################################################################

installPytz() {
# Eggs are described at https://pythonhosted.org/pytz/formats.html
# Args below work on Windows
  local PYTZ_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/pytz.files'"
  mkdir -p $PYTHON_SITEPKGSDIR
  if bilderDuInstall pytz "$PYTZ_INSTALL_ARGS" "$PYTZ_ENV"; then
    : # chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


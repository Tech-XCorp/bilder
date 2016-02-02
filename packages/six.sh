#!/bin/bash
#
# Build information for six
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in six_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/six_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSixNonTriggerVars() {
  SIX_UMASK=002
}
setSixNonTriggerVars

#####################################################################
#
# Build six
#
######################################################################

buildSix() {

# Check for build need
  if ! bilderUnpack six; then
    return 1
  fi

# Remove eggs and pth as Bilder manages
  cmd="rm -rf ${PYTHON_SITEPKGSDIR}/six*.{egg,pth}"
  techo -2 "$cmd"
  $cmd

# Build away
  SIX_ENV="$DISTUTILS_ENV"
  techo -2 SIX_ENV = $SIX_ENV
  bilderDuBuild six '-' "$SIX_ENV"

}

######################################################################
#
# Test six
#
######################################################################

testSix() {
  techo "Not testing six."
}

######################################################################
#
# Install six
#
######################################################################

installSix() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/six/formats.html
# Args below work on windows.
  local SIX_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/six.files'"
  if bilderDuInstall six "$SIX_INSTALL_ARGS" "$SIX_ENV"; then
    : # chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


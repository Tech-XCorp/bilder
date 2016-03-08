#!/bin/bash
#
# Build information for roman
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in roman_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/roman_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setRomanNonTriggerVars() {
  ROMAN_UMASK=002
}
setRomanNonTriggerVars

#####################################################################
#
# Build roman
#
######################################################################

buildRoman() {

# Check for build need
  if ! bilderUnpack roman; then
    return 1
  fi

# Build away
  ROMAN_ENV="$DISTUTILS_ENV"
  techo -2 ROMAN_ENV = $ROMAN_ENV
  bilderDuBuild roman '-' "$ROMAN_ENV"

}

######################################################################
#
# Test roman
#
######################################################################

testRoman() {
  techo "Not testing roman."
}

######################################################################
#
# Install roman
#
######################################################################

installRoman() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/setuptools/formats.html
  # local ROMAN_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/roman.files'"
  local ROMAN_INSTALL_ARGS="--record='$PYTHON_SITEPKGSDIR/roman.files'"
  if bilderDuInstall roman "$ROMAN_INSTALL_ARGS" "$ROMAN_ENV"; then
    : # chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


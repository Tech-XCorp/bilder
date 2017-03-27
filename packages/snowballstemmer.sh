#!/bin/sh
######################################################################
#
# @file    snowballstemmer.sh
#
# @brief   Build information for snowballstemmer.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in snowballstemmer_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/snowballstemmer_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSnowballstemmerNonTriggerVars() {
  SNOWBALLSTEMMER_UMASK=002
}
setSnowballstemmerNonTriggerVars

#####################################################################
#
# Build snowballstemmer
#
######################################################################

buildSnowballstemmer() {

# Check for build need
  if ! bilderUnpack snowballstemmer; then
    return 1
  fi

# Build away
  SNOWBALLSTEMMER_ENV="$DISTUTILS_ENV"
  techo -2 SNOWBALLSTEMMER_ENV = $SNOWBALLSTEMMER_ENV
  bilderDuBuild snowballstemmer '-' "$SNOWBALLSTEMMER_ENV"

}

######################################################################
#
# Test snowballstemmer
#
######################################################################

testSnowballstemmer() {
  techo "Not testing snowballstemmer."
}

######################################################################
#
# Install snowballstemmer
#
######################################################################

installSnowballstemmer() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/setuptools/formats.html
  # local SNOWBALLSTEMMER_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/snowballstemmer.files'"
  local SNOWBALLSTEMMER_INSTALL_ARGS="--record='$PYTHON_SITEPKGSDIR/snowballstemmer.files'"
  if bilderDuInstall snowballstemmer "$SNOWBALLSTEMMER_INSTALL_ARGS" "$SNOWBALLSTEMMER_ENV"; then
    : # chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


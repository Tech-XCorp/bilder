#!/bin/sh
######################################################################
#
# @file    alabaster.sh
#
# @brief   Build information for alabaster
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in alabaster_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/alabaster_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setAlabasterNonTriggerVars() {
  ALABASTER_UMASK=002
}
setAlabasterNonTriggerVars

#####################################################################
#
# Build alabaster
#
######################################################################

buildAlabaster() {

# Check for build need
  if ! bilderUnpack alabaster; then
    return 1
  fi

# Build away
  ALABASTER_ENV="$DISTUTILS_ENV"
  techo -2 ALABASTER_ENV = $ALABASTER_ENV
  bilderDuBuild alabaster '-' "$ALABASTER_ENV"

}

######################################################################
#
# Test alabaster
#
######################################################################

testAlabaster() {
  techo "Not testing alabaster."
}

######################################################################
#
# Install alabaster
#
######################################################################

installAlabaster() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/alabaster/formats.html
# It seems that packages are using alabaster which creates eggs, which
# for some reason we are not finding.  Moreover, different packages are
# installing difference eggs of their dependencies.
  local ALABASTER_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/alabaster.files'"
  if bilderDuInstall alabaster "$ALABASTER_INSTALL_ARGS" "$ALABASTER_ENV"; then
    : # chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


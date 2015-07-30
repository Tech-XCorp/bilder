#!/bin/bash
#
# Build information for colorama
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in colorama_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/colorama_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setColoramaNonTriggerVars() {
  COLORAMA_UMASK=002
}
setColoramaNonTriggerVars

#####################################################################
#
# Build colorama
#
######################################################################

buildColorama() {

# Check for build need
  if ! bilderUnpack colorama; then
    return 1
  fi

# Build away
  COLORAMA_ENV="$DISTUTILS_ENV"
  techo -2 COLORAMA_ENV = $COLORAMA_ENV
  bilderDuBuild colorama '-' "$COLORAMA_ENV"

}

######################################################################
#
# Test colorama
#
######################################################################

testColorama() {
  techo "Not testing colorama."
}

######################################################################
#
# Install colorama
#
######################################################################

installColorama() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/colorama/formats.html
# It seems that packages are using colorama which creates eggs, which
# for some reason we are not finding.  Moreover, different packages are
# installing difference eggs of their dependencies.
  local COLORAMA_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/colorama.filelist'"
  if bilderDuInstall colorama "$COLORAMA_INSTALL_ARGS" "$COLORAMA_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


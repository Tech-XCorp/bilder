#!/bin/bash
#
# Build information for sphinx
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in sphinx_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/sphinx_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSphinxNonTriggerVars() {
  SPHINX_UMASK=002
}
setSphinxNonTriggerVars

#####################################################################
#
# Launch sphinx builds.
#
######################################################################

buildSphinx() {

# Get sphinx, check for build need
  if ! bilderUnpack Sphinx; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/Sphinx*"
  techo "$cmd"
# Do second time for cygwin
  if ! $cmd; then
    techo "$cmd"
    $cmd
  fi

# Build away
  SPHINX_ENV="$DISTUTILS_ENV"
  techo -2 SPHINX_ENV = $SPHINX_ENV
  bilderDuBuild Sphinx '-' "$SPHINX_ENV"

}

######################################################################
#
# Test sphinx
#
######################################################################

testSphinx() {
  techo "Not testing Sphinx."
}

######################################################################
#
# Install sphinx
#
######################################################################

installSphinx() {
# Possible options: --single-version-externally-managed
  local SPHINX_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/sphinx.filelist'"
  if bilderDuInstall Sphinx "$SPHINX_INSTALL_ARGS" "$SPHINX_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/easy-install.pth
    setOpenPerms $PYTHON_SITEPKGSDIR/{S,s}phinx-*.egg
    setOpenPerms $PYTHON_SITEPKGSDIR/Jinja2-*.egg
  fi
}


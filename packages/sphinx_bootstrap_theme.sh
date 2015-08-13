#!/bin/bash
#
# Build information for sphinx_bootstrap_theme
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in sphinx_bootstrap_theme_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/sphinx_bootstrap_theme_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSphinx_bootstrap_themeNonTriggerVars() {
  SPHINX_BOOTSTRAP_THEME_UMASK=002
}
setSphinx_bootstrap_themeNonTriggerVars

#####################################################################
#
# Build sphinx_bootstrap_theme
#
######################################################################

buildSphinx_bootstrap_theme() {

# Check for build need
  if ! bilderUnpack sphinx_bootstrap_theme; then
    return 1
  fi

# Build away
  SPHINX_BOOTSTRAP_THEME_ENV="$DISTUTILS_ENV"
  techo -2 SPHINX_BOOTSTRAP_THEME_ENV = $SPHINX_BOOTSTRAP_THEME_ENV
  bilderDuBuild sphinx_bootstrap_theme '-' "$SPHINX_BOOTSTRAP_THEME_ENV"

}

######################################################################
#
# Test sphinx_bootstrap_theme
#
######################################################################

testSphinx_bootstrap_theme() {
  techo "Not testing sphinx_bootstrap_theme."
}

######################################################################
#
# Install sphinx_bootstrap_theme
#
######################################################################

installSphinx_bootstrap_theme() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/sphinx_bootstrap_theme/formats.html
# It seems that packages are using sphinx_bootstrap_theme which creates eggs, which
# for some reason we are not finding.  Moreover, different packages are
# installing difference eggs of their dependencies.
  local SPHINX_BOOTSTRAP_THEME_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/sphinx_bootstrap_theme.filelist'"
  if bilderDuInstall sphinx_bootstrap_theme "$SPHINX_BOOTSTRAP_THEME_INSTALL_ARGS" "$SPHINX_BOOTSTRAP_THEME_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


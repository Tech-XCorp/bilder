#!/bin/bash
#
# Build information for sphinx_rtd_theme
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in sphinx_rtd_theme_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/sphinx_rtd_theme_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSphinx_rtd_themeNonTriggerVars() {
  SPHINX_RTD_THEME_UMASK=002
}
setSphinx_rtd_themeNonTriggerVars

#####################################################################
#
# Build sphinx_rtd_theme
#
######################################################################

buildSphinx_rtd_theme() {

# Check for build need
  if ! bilderUnpack sphinx_rtd_theme; then
    return 1
  fi

# Build away
  SPHINX_RTD_THEME_ENV="$DISTUTILS_ENV"
  techo -2 SPHINX_RTD_THEME_ENV = $SPHINX_RTD_THEME_ENV
  bilderDuBuild sphinx_rtd_theme '-' "$SPHINX_RTD_THEME_ENV"

}

######################################################################
#
# Test sphinx_rtd_theme
#
######################################################################

testSphinx_rtd_theme() {
  techo "Not testing sphinx_rtd_theme."
}

######################################################################
#
# Install sphinx_rtd_theme
#
######################################################################

installSphinx_rtd_theme() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/sphinx_rtd_theme/formats.html
# It seems that packages are using sphinx_rtd_theme which creates eggs, which
# for some reason we are not finding.  Moreover, different packages are
# installing difference eggs of their dependencies.
  local SPHINX_RTD_THEME_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/sphinx_rtd_theme.filelist'"
  if bilderDuInstall sphinx_rtd_theme "$SPHINX_RTD_THEME_INSTALL_ARGS" "$SPHINX_RTD_THEME_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


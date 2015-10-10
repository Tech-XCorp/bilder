#!/bin/bash
#
# Build information for setuptools
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in setuptools_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/setuptools_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSetuptoolsNonTriggerVars() {
  SETUPTOOLS_UMASK=002
}
setSetuptoolsNonTriggerVars

#####################################################################
#
# Build setuptools
#
######################################################################

buildSetuptools() {

# Check for build need
  if ! bilderUnpack setuptools; then
    return 1
  fi

# Build away
  SETUPTOOLS_ENV="$DISTUTILS_ENV"
  techo -2 SETUPTOOLS_ENV = $SETUPTOOLS_ENV
  bilderDuBuild setuptools '-' "$SETUPTOOLS_ENV"

}

######################################################################
#
# Test setuptools
#
######################################################################

testSetuptools() {
  techo "Not testing setuptools."
}

######################################################################
#
# Install setuptools
#
######################################################################

installSetuptools() {
  mkdir -p $PYTHON_SITEPKGSDIR
# Eggs are described at https://pythonhosted.org/setuptools/formats.html
# It seems that packages are using setuptools which creates eggs, which
# for some reason we are not finding.  Moreover, different packages are
# installing difference eggs of their dependencies.
  local SETUPTOOLS_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/setuptools.filelist'"
  if bilderDuInstall setuptools "$SETUPTOOLS_INSTALL_ARGS" "$SETUPTOOLS_ENV"; then
    if test -e $PYTHON_SITEPKGSDIR/site.py; then
      chmod a+r $PYTHON_SITEPKGSDIR/site.py*
    fi
  fi
}


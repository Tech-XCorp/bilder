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
# Remove old setuptools-installed hacky site.py.
# http://stackoverflow.com/questions/26451807/pythons-site-py-gone-after-yosemite-upgrade-is-that-okay
  cmd="rm -rf ${PYTHON_SITEPKGSDIR}/site.{py,pyc}"
  techo -2 "$cmd"
  $cmd
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
# installing different eggs of their dependencies.  The flag,
# --single-version-externally-managed, lets Bilder take over the management
# so that we have a single installation.  But then we have to make sure
# that wrong installations are cleaned out.
  rm -rf $PYTHON_SITEPKGSDIR/setuptools*.{egg,pth}
  local SETUPTOOLS_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/setuptools.filelist'"
  if bilderDuInstall setuptools "$SETUPTOOLS_INSTALL_ARGS" "$SETUPTOOLS_ENV"; then
    if test -e $PYTHON_SITEPKGSDIR/site.py; then
      chmod a+r $PYTHON_SITEPKGSDIR/site.py*
    fi
  fi
}


#!/bin/bash
#
# Version and build information for setuptools
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SETUPTOOLS_BLDRVERSION_STD=${SETUPTOOLS_BLDRVERSION_STD:-"2.0.2"}
SETUPTOOLS_BLDRVERSION_EXP=${SETUPTOOLS_BLDRVERSION_EXP:-"2.0.2"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setSetupToolsGlobalVars() {
  SETUPTOOLS_BUILDS=${SETUPTOOLS_BUILDS:-"cc4py"}
  SETUPTOOLS_DEPS=Python
  SETUPTOOLS_UMASK=002
}
setSetupToolsGlobalVars

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
  if bilderDuInstall setuptools " " "$SETUPTOOLS_ENV"; then
    chmod a+r $PYTHON_SITEPKGSDIR/site.py*
  fi
}


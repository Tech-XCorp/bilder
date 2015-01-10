#!/bin/bash
#
# Version and build information for pyreadline
# Pure python implemention of readline for Windows only
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYREADLINE_BLDRVERSION=${PYREADLINE_BLDRVERSION:-"1.7.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$PYREADLINE_BUILDS"; then
  if [[ `uname` =~ CYGWIN* ]]; then
    PYREADLINE_BUILDS=pycsh
  fi
fi
# setuptools gets site-packages correct
PYREADLINE_DEPS=Python
PYREADLINE_UMASK=002

#####################################################################
#
# Launch pyreadline builds.
#
######################################################################

buildPyreadline() {

  if bilderUnpack pyreadline; then
# Build away
    PYREADLINE_ENV="$DISTUTILS_ENV"
    techo -2 PYREADLINE_ENV = $PYREADLINE_ENV
    bilderDuBuild pyreadline
  fi

}

######################################################################
#
# Test pyreadline
#
######################################################################

testPyreadline() {
  techo "Not testing pyreadline."
}

######################################################################
#
# Install pyreadline
#
######################################################################

installPyreadline() {
  bilderDuInstall -r pyreadline pyreadline
}


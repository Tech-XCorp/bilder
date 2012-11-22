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
# Other values
#
######################################################################

PYREADLINE_BUILDS=${PYREADLINE_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
PYREADLINE_DEPS=Python
PYREADLINE_UMASK=002

######################################################################
#
# This is only for Windows
#
######################################################################
case `uname` in
  Darwin*)
	  unset PYREADLINE_BUILDS
	  ;;
  Linux)
	  unset PYREADLINE_BUILDS
    ;;
esac


#####################################################################
#
# Launch pyreadline builds.
#
######################################################################

buildPyreadline() {

  if bilderUnpack pyreadline; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/pyreadline*"
    techo "$cmd"
    $cmd

# Build away
    PYREADLINE_ENV="$DISTUTILS_ENV"
    techo -2 PYREADLINE_ENV = $PYREADLINE_ENV
    bilderDuBuild -p pyreadline pyreadline "--inplace" "$PYREADLINE_ENV"
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
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p pyreadline pyreadline '-' "$PYREADLINE_ENV"
      ;;
  esac
}


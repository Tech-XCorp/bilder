#!/bin/bash
#
# Version and build information for mercurial
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MERCURIAL_BLDRVERSION=${MERCURIAL_BLDRVERSION:-"2.3.1"}

######################################################################
#
# Other values
#
######################################################################

MERCURIAL_BUILDS=${MERCURIAL_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
MERCURIAL_DEPS=Python
MERCURIAL_UMASK=002

######################################################################
#
# Launch mercurial builds.
#
######################################################################

buildMercurial() {
  if bilderUnpack mercurial; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/mercurial*"
    techo "$cmd"
    $cmd

# Build away
    MERCURIAL_ENV="$DISTUTILS_ENV"
    decho MERCURIAL_ENV = $MERCURIAL_ENV
    bilderDuBuild -p mercurial mercurial "build_ext --inplace" "$MERCURIAL_ENV"
  fi
}

######################################################################
#
# Test mercurial
#
######################################################################

testMercurial() {
  techo "Not testing mercurial."
}

######################################################################
#
# Install mercurial
#
######################################################################

installMercurial() {
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p mercurial mercurial '-' "$MERCURIAL_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p mercurial mercurial "--install-purelib=$PYTHON_SITEPKGSDIR" "$MERCURIAL_ENV"
      ;;
  esac  
}


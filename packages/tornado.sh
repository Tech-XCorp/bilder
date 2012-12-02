#!/bin/bash
#
# Version and build information for tornado
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

TORNADO_BLDRVERSION=${TORNADO_BLDRVERSION:-"2.1.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

TORNADO_BUILDS=${TORNADO_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
TORNADO_DEPS=setuptools,Python
TORNADO_UMASK=002

#####################################################################
#
# Launch builds
#
######################################################################

buildTornado() {
  if bilderUnpack tornado; then
# Build away
    TORNADO_ENV="$DISTUTILS_ENV"
    techo -2 TORNADO_ENV = $TORNADO_ENV
    bilderDuBuild tornado "" "$TORNADO_ENV"
  fi
}

######################################################################
#
# Test
#
######################################################################

testTornado() {
  techo "Not testing tornado."
}

######################################################################
#
# Install
#
######################################################################

installTornado() {
if false; then
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -r tornado tornado "" "$TORNADO_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -r tornado tornado "--install-purelib=$PYTHON_SITEPKGSDIR" "$TORNADO_ENV"
      ;;
  esac
fi
# 20121202: There is only one lib dir.  No lib64 now.
  bilderDuInstall -r tornado tornado "" "$TORNADO_ENV"
}


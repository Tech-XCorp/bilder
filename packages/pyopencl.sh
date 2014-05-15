#!/bin/bash
#
# Version and build information for pyopencl
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYOPENCL_BLDRVERSION_STD=${PYOPENCL_BLDRVERSION_STD:-"2013.2"}

######################################################################
#
# Builds and deps
#
######################################################################

PYOPENCL_BUILDS=${PYOPENCL_BUILDS:-"cc4py"}
PYOPENCL_DEPS=

######################################################################
#
# Launch pyopencl builds.
#
######################################################################

buildPyopencl() {
  if ! bilderUnpack pyopencl; then
    return
  fi
  bilderDuBuild pyopencl "$PYOPENCL_ARGS" "$PYOPENCL_ENV"
}

######################################################################
#
# Test pyopencl
#
######################################################################

testPyopencl() {
  techo "Not testing pyopencl."
}

######################################################################
#
# Install pyopencl
#
######################################################################

installPyopencl() {
  case `uname` in
    CYGWIN*)
      bilderDuInstall -n pyopencl "$PYOPENCL_ARGS" "$PYOPENCL_ENV"
      ;;
    *)
      bilderDuInstall -r pyopencl pyopencl "$PYOPENCL_ARGS" "$PYOPENCL_ENV"
      ;;
  esac
}

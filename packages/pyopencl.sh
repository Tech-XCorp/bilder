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
# DM 5/15/2014:
# PyOpenCL depends on an OpenCL platform.  However, they're are many
# different choices available and there is no reasonable default.
# Therefore I leave OpenCL out of the PYOPENCL_DEPS for now. Building
# will fail if no OpenCL platform can be found.  Typical choices for
# OpenCL platforms would be:
# NVIDIA GPU machines: cuda toolkit
# AMD GPU machines: AMD APP SDK
# CPU only: AMD APP SDK or intel OpenCL SDK
# Altera FPGA: Altera OpenCL SDK
PYOPENCL_DEPS=boost

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

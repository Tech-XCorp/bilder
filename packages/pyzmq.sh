#!/bin/bash
#
# Version and build information for pyzmq
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYZMQ_BLDRVERSION=${PYZMQ_BLDRVERSION:-"63d88b0"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$PYZMQ_BUILDS"; then
  if ! [[ `uname` =~ CYGWIN ]]; then
    PYZMQ_BUILDS="cc4py"
  fi
fi
# setuptools gets site-packages correct
PYZMQ_DEPS=setuptools,Python,zeromq,Cython
PYZMQ_UMASK=002

#####################################################################
#
# Launch PyZMQ builds.
#
######################################################################

buildPyzmq() {

  if bilderUnpack pyzmq; then
# Build away
    PYZMQ_ENV="$DISTUTILS_ENV"
    techo -2 "PYZMQ_ENV = $PYZMQ_ENV"
# 20121202: Is rpath correct?  Why not lib subdir?  Only for Linux?
    ZEROMQ_ARG="--rpath=$CONTRIB_DIR/zeromq-cc4py --zmq=$CONTRIB_DIR/zeromq-cc4py"
    bilderDuBuild pyzmq "build_ext $ZEROMQ_ARG --inplace" "$PYZMQ_ENV"
  fi

}

######################################################################
#
# Test pyzmq
#
######################################################################

testPyzmq() {
  techo "Not testing pyzmq."
}

######################################################################
#
# Install Pyzmq
#
######################################################################

installPyzmq() {
  # mkdir -p $PYTHON_SITEPKGSDIR
  # bilderDuInstall -r pyzmq pyzmq "--install-purelib=$PYTHON_SITEPKGSDIR" "$PYZMQ_ENV"
  bilderDuInstall -r pyzmq pyzmq "" "$PYZMQ_ENV"
}


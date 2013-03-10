#!/bin/bash
#
# Build and installationn of pyzmq
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
# Launch builds
#
######################################################################

buildPyzmq() {

  if bilderUnpack pyzmq; then
# Build away
    PYZMQ_ENV="$DISTUTILS_ENV"
    techo -2 "PYZMQ_ENV = $PYZMQ_ENV"
    PYZMQ_ARGS="build_ext --inplace --zmq=$CONTRIB_DIR/zeromq-$FORPYTHON_BUILD"
    if [[ `uname` =~ Linux ]]; then
      PYZMQ_ARG="$PYZMQ_ARGS --rpath=$CONTRIB_DIR/zeromq-$FORPYTHON_BUILD"
    fi
    bilderDuBuild pyzmq "$PYZMQ_ARGS" "$PYZMQ_ENV"
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
  bilderDuInstall -r pyzmq pyzmq "" "$PYZMQ_ENV"
}


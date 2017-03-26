#!/bin/sh
######################################################################
#
# @file    pyzmq.sh
#
# @brief   Version and build information for pyzmq.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYZMQ_BLDRVERSION_STD=${PYZMQ_BLDRVERSION_STD:-"13.0.0"}
PYZMQ_BLDRVERSION_EXP=${PYZMQ_BLDRVERSION_EXP:-"14.1.0"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setPyzmqGlobalVars() {
  if ! [[ `uname` =~ CYGWIN ]]; then
    PYZMQ_BUILDS=${PYZMQ_BUILDS:-"pycsh"}
  fi
# setuptools gets site-packages correct
  PYZMQ_DEPS=setuptools,Python,zeromq,Cython
  PYZMQ_UMASK=002
}
setPyzmqGlobalVars

#####################################################################
#
# Launch builds
#
######################################################################

buildPyzmq() {

  if ! bilderUnpack pyzmq; then
    return
  fi

# Build away
  PYZMQ_ENV="$DISTUTILS_ENV"
  techo -2 "PYZMQ_ENV = $PYZMQ_ENV"
  PYZMQ_ARGS="build_ext --inplace --zmq=$CONTRIB_DIR/zeromq-$FORPYTHON_SHARED_BUILD"
  if [[ `uname` =~ Linux ]]; then
    PYZMQ_ARG="$PYZMQ_ARGS --rpath=$CONTRIB_DIR/zeromq-$FORPYTHON_SHARED_BUILD"
  fi
  bilderDuBuild pyzmq "$PYZMQ_ARGS" "$PYZMQ_ENV"

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


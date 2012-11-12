#!/bin/bash
#
# Version and build information for pyzmq
#
# $Id: pyzmq.sh 5630 2012-03-30 19:32:23Z kruger $
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
# Other values
#
######################################################################

PYZMQ_BUILDS=${PYZMQ_BUILDS:-"cc4py"}
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
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/pyzmq*"
    techo "$cmd"
    $cmd

# Build away
    PYZMQ_ENV="$DISTUTILS_ENV"
    decho PYZMQ_ENV = $PYZMQ_ENV
    ZEROMQ_ARG="--rpath=$CONTRIB_DIR/zeromq --zmq=$CONTRIB_DIR/zeromq"
    bilderDuBuild -p pyzmq pyzmq "build_ext $ZEROMQ_ARG --inplace" "$PYZMQ_ENV"
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
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p pyzmq pyzmq '-' "$PYZMQ_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p pyzmq pyzmq "--install-purelib=$PYTHON_SITEPKGSDIR" "$PYZMQ_ENV"
      ;;
  esac
}


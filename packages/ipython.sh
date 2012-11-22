#!/bin/bash
#
# Version and build information for ipython
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

IPYTHON_BLDRVERSION=${IPYTHON_BLDRVERSION:-"0.12"}
#IPYTHON_BLDRVERSION=${IPYTHON_BLDRVERSION:-"0.10.2"}

######################################################################
#
# Other values
#
######################################################################

IPYTHON_BUILDS=${IPYTHON_BUILDS:-"cc4py"}
IPYTHON_DEPS=Python,tornado,pyzmq,zeromq,pyqt,pyreadline,readline,ncurses,matplotlib
IPYTHON_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/bin
addtopathvar PATH $BLDR_INSTALL_DIR/bin

#####################################################################
#
# Launch ipython builds.
#
######################################################################

buildIpython() {

  if bilderUnpack ipython; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/ipython*"
    techo "$cmd"
    $cmd

# Build away
    IPYTHON_ENV="$DISTUTILS_ENV"
    techo -2 IPYTHON_ENV = $IPYTHON_ENV
    bilderDuBuild -p ipython ipython '-' "$IPYTHON_ENV"
  fi

}

######################################################################
#
# Test IPYTHON
#
######################################################################

testIpython() {
  techo "Not testing ipython."
}

######################################################################
#
# Install ipython
#
######################################################################

installIpython() {
  case `uname` in
    # Windows does not have a lib versus lib64 issue
    CYGWIN*)
      bilderDuInstall -p ipython ipython " " "$IPYTHON_ENV"
      ;;
    *)
      bilderDuInstall -p ipython ipython "--install-purelib=$PYTHON_SITEPKGSDIR" "$IPYTHON_ENV"
      ;;
  esac
}

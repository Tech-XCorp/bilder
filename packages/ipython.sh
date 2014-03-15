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

IPYTHON_BLDRVERSION_STD=${IPYTHON_BLDRVERSION_STD:-"1.1.0"}
IPYTHON_BLDRVERSION_EXP=${IPYTHON_BLDRVERSION_EXP:-"1.2.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setIpythonGlobalVars() {
  IPYTHON_BUILDS=${IPYTHON_BUILDS:-"cc4py"}
  IPYTHON_DEPS=Python,tornado,pyzmq,zeromq,pyreadline,readline,ncurses,matplotlib
  case `uname` in
    Darwin) ;;
    *) IPYTHON_DEPS=${IPYTHON_DEPS},pyqt ;;
  esac
  IPYTHON_UMASK=002
  addtopathvar PATH $CONTRIB_DIR/bin
  addtopathvar PATH $BLDR_INSTALL_DIR/bin
}
setIpythonGlobalVars

#####################################################################
#
# Launch ipython builds.
#
######################################################################

buildIpython() {

  if ! bilderUnpack ipython; then
    return
  fi

# Remove all old installations
  cmd="rmall ${PYTHON_SITEPKGSDIR}/ipython*"
  techo "$cmd"
  $cmd

# Build away
  IPYTHON_ENV="$DISTUTILS_ENV"
  techo -2 IPYTHON_ENV = $IPYTHON_ENV
  bilderDuBuild -p ipython ipython '-' "$IPYTHON_ENV"

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
  bilderDuInstall -p ipython ipython " " "$IPYTHON_ENV"
}


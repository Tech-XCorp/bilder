#!/bin/bash
#
# Version and build information for geant4
#
# $Id$
#
######################################################################

######################################################################
#
# Version and finding.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/geant4_aux.sh

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setGeant4GlobalVars() {
  GEANT4_BUILDS=${GEANT4_BUILDS:-"$FORPYTHON_BUILD"}
  if which qmake 1>/dev/null 2>&1; then
    GEANT4_DEPS=qt
  fi
  GEANT4_DEPS=$GEANT4_DEPS,pcre,xercesc,cmake
  trimvar GEANT4_DEPS ,
  addtopathvar PATH $CONTRIB_DIR/geant4-$FORPYTHON_BUILD/bin
}
setGeant4GlobalVars

######################################################################
#
# Launch geant4 builds.
#
######################################################################

buildGeant4() {
  if ! bilderUnpack geant4; then
    return
  fi
  local GEANT4_CONFIG_ARGS=
  GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_OPENGL_X11:BOOL=ON -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML:BOOL=ON -DXERCESC_ROOT_DIR:PATH='$CONTRIB_DIR/xercesc-$FORPYTHON_BUILD'"
  if which qmake 1>/dev/null 2>&1; then
    GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_QT:BOOL=ON"
  fi
  case `uname` in
    Linux) GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_SYSTEM_EXPAT:BOOL=OFF";;
  esac
  if bilderConfig -c geant4 $FORPYTHON_BUILD "$GEANT4_CONFIG_ARGS"; then
    bilderBuild geant4 $FORPYTHON_BUILD "$GEANT4_MAKEJ_ARGS"
  fi
}

######################################################################
#
# Test geant4
#
######################################################################

testGeant4() {
  techo "Not testing geant4."
}

######################################################################
#
# Install geant4
#
######################################################################

installGeant4() {
  bilderInstallAll geant4
  findGeant4
}


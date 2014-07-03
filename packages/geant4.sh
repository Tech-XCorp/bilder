#!/bin/bash
#
# Build information for geant4
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in geant4_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/geant4_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setGeant4NonTriggerVars() {
  GEANT4_MASK=002
}
setGeant4NonTriggerVars

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
  GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML:BOOL=ON -DXERCESC_ROOT_DIR:PATH='$CONTRIB_DIR/xercesc-$FORPYTHON_BUILD'"
  case `uname` in
    Darwin)
# Geant requires X11 for opengl and qt
      if test -d /usr/X11 -o -d /opt/X11; then
        GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_OPENGL_X11:BOOL=ON"
        if which qmake 1>/dev/null 2>&1; then
           GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_QT:BOOL=ON"
        fi
      fi
      ;;
    Linux)
      GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_SYSTEM_EXPAT:BOOL=OFF"
      ;;
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
  bilderInstallAll geant4 " -r"
}

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

# Determine whether to build
  if ! bilderUnpack -c geant4; then
    return
  fi

# Get library names
  local libpost=
  local libpre=
  case `uname` in
    CYGWIN*)
      libpost=lib
      ;;
    Darwin)
      libpre=lib
      libpost=dylib
      ;;
    Linux)
      libpre=lib
      libpost=so
      ;;
  esac
  local xercescdir="${CONTRIB_DIR}/xercesc-$FORPYTHON_SHARED_BUILD"

  if ! bilderUnpack geant4; then
    return
  fi

  local GEANT4_CONFIG_ARGS="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
  GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_INSTALL_DATA:BOOL=ON -DGEANT4_INSTALL_DATADIR:PATH='$CONTRIB_DIR/geant4-$FORPYTHON_SHARED_BUILD/share/Geant4-9.6.3/data' -DGEANT4_USE_GDML:BOOL=ON -DXERCESC_ROOT_DIR:PATH='$CONTRIB_DIR/xercesc-$FORPYTHON_SHARED_BUILD' -DXERCESC_INCLUDE_DIR:PATH='${xercescdir}/include' -DXERCESC_LIBRARY:FILEPATH='${xercescdir}/lib/${libpre}xerces-c.$libpost'"

  case `uname` in
    Darwin)
      local qtdir="${CONTRIB_DIR}/qt-$FORPYTHON_SHARED_BUILD"
# Geant requires X11 for opengl and qt
      if test -d /usr/X11 -o -d /opt/X11; then
        GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_OPENGL_X11:BOOL=ON"
        if which qmake 1>/dev/null 2>&1; then
           GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_QT:BOOL=ON -DQT_INCLUDE_DIR:PATH='${qtdir}/include'"
        fi
      fi
      ;;
    Linux)
      GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_USE_SYSTEM_EXPAT:BOOL=OFF"
      ;;
  esac
# Timeouts occurring on txmtnlion
  GEANT4_CONFIG_ARGS="${GEANT4_CONFIG_ARGS} -DGEANT4_INSTALL_DATA_TIMEOUT:STRING=3000"
  local otherargsvar=` genbashvar GEANT4_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig -c geant4 $FORPYTHON_SHARED_BUILD "$GEANT4_CONFIG_ARGS $otherargs"; then
    bilderBuild geant4 $FORPYTHON_SHARED_BUILD "$GEANT4_MAKEJ_ARGS"
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

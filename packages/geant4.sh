#!/bin/bash
#
# Version and build information for geant4
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GEANT4_BLDRVERSION=${GEANT4_BLDRVERSION:-"10.00.p01"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setGeant4GlobalVars() {
  GEANT4_BUILDS=${GEANT4_BUILDS:-"ser"}
  GEANT4_DEPS=cmake,pcre,xercesc
  case `uname` in
    CYGWIN*) ;;
    Darwin) ;;
    Linux)
      GEANT4_ARGS="${GEANT4_ARGS} -DGEANT4_USE_SYSTEM_EXPAT:BOOL=OFF"
      ;;
  esac
  addtopathvar PATH $CONTRIB_DIR/geant4/bin
}
setGeant4GlobalVars

######################################################################
#
# Launch geant4 builds.
#
######################################################################

buildGeant4() {
  if bilderUnpack geant4; then
    GEANT4_ARGS="${GEANT4_ARGS} -DGEANT4_USE_QT:BOOL=ON -DGEANT4_USE_OPENGL_X11:BOOL=ON -DGEANT4_INSTALL_DATA=ON -DGEANT4_USE_GDML:BOOL=ON -DXERCESC_ROOT_DIR:PATH='$CONTRIB_DIR/xercesc'"
    if bilderConfig -c geant4 ser "$GEANT4_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild geant4 ser ""
    fi
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
  bilderInstall -r geant4 ser geant4
  local GEANT4_HOME="$BLDR_INSTALL_DIR/geant4"
  export G4DATA="$GEANT4_HOME/share/Geant4-9.6.2/data"
  export G4LEDATA="$G4DATA/G4EMLOW6.32"
  export G4LEVELGAMMADATA="$G4DATA/PhotonEvaporation2.3"
  export G4NEUTRONXSDATA="$G4DATA/G4NEUTRONXS1.2"
  export G4SAIDXSDATA="$G4DATA/G4SAIDDATA1.1"
# The following lines introduce new env vars such as
# G4INSTALL, G4INCLUDE etc.  Not sure if we use them as they are no cmake.
#  . $GEANT4_HOME/bin/geant4.sh
#  . $GEANT4_HOME/share/Geant4-9.6.2/geant4make/geant4make.sh
}


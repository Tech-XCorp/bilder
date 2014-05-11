#!/bin/bash
#
# Version and build information for gras
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GRAS_BLDRVERSION=${GRAS_BLDRVERSION:-"03-03-r1561"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setGrasGlobalVars() {
  GRAS_BUILDS=${GRAS_BUILDS:-"ser"}
  GRAS_DEPS=geant4
  addtopathvar PATH $CONTRIB_DIR/gras/bin
}
setGrasGlobalVars

######################################################################
#
# Launch gras builds.
#
######################################################################

buildGras() {
  #GRAS_SER_INSTALL_DIR=$CONTRIB_DIR
  #GRAS_SER_BUILD_DIR=$BUILD_DIR/gras-$GRAS_BLDRVERSION/ser
  G4INSTALL="$CONTRIB_DIR/geant4"
  export G4INSTALL
  source $G4INSTALL/bin/geant4.sh

  GRAS_ENV="$GRAS_ENV G4INSTALL='$G4INSTALL'"

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


  local xercescdir="${CONTRIB_DIR}/xercesc"

  GRAS_ADDL_ARGS="${GRAS_ADDL_ARGS} -DXERCESC_INCLUDE_DIR:PATH='${xercesc}/include' -DXERCESC_LIBRARY:FILEPATH='${xercescdir}/lib/${libpre}xerces-c.$libpost' -DGeant4_DIR:PATH='$CONTRIB_DIR/geant4/lib/Geant4-9.6.2' -DGRAS_INSTALL_PREFIX:PATH='$CONTRIB_DIR/gras'"

  if bilderUnpack gras; then
    if bilderConfig -c gras ser "$GRAS_ADDL_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild gras ser "" "$GRAS_ENV"
    fi
  fi
}

######################################################################
#
# Test gras
#
######################################################################

testGras() {
  techo "Not testing gras."
}

######################################################################
#
# Install gras
#
######################################################################

installGras() {
  bilderInstall -r gras ser gras
  local GRAS_HOME="$BLDR_INSTALL_DIR/gras"
  techo "GRAS_HOME = $GRAS_HOME"
  export GEANT4_HOME="$CONTRIB_DIR/geant4"
  export G4DATA="$GEANT4_HOME/share/Geant4-9.6.2/data"
  export G4LEDATA="$G4DATA/G4EMLOW6.32"
  export G4LEVELGAMMADATA="$G4DATA/PhotonEvaporation2.3"
  export G4NEUTRONXSDATA="$G4DATA/G4NEUTRONXS1.2"
  export G4SAIDXSDATA="$G4DATA/G4SAIDDATA1.1"

  . $GRAS_HOME/bin/gras-env.sh
}


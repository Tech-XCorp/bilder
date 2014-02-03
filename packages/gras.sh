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
# Other values
#
######################################################################

GRAS_BUILDS=${GRAS_BUILDS:-"ser"}
GRAS_DEPS=geant4,pcre,xercesc

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/gras/bin

######################################################################
#
# Launch gras builds.
#
######################################################################

buildGras() {
  GRAS_SER_INSTALL_DIR=$CONTRIB_DIR
  GRAS_SER_BUILD_DIR=$BUILD_DIR/gras-$GRAS_BLDRVERSION/ser
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

  GRAS_ADDL_ARGS="${GRAS_ADDL_ARGS} -DXERCESC_INCLUDE_DIR:PATH='${xercesc}/include' -DXERCESC_LIBRARY:FILEPATH='${xercescdir}/lib/${libpre}xerces-c-3.1.$libpost' -DGeant4_DIR:PATH='$CONTRIB_DIR/geant4/lib/Geant4-9.6.2'"

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
  local GRAS_HOME="$BLDR_INSTALL_DIR/geant4"
  . $GRAS_HOME/bin/gras-env.sh
}


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

GEANT4_BLDRVERSION=${GEANT4_BLDRVERSION:-"9.6.p02"}

######################################################################
#
# Other values
#
######################################################################

GEANT4_BUILDS=${GEANT4_BUILDS:-"ser"}
GEANT4_DEPS=cmake,pcre,xercesc

case `uname` in
  CYGWIN*)
    ;;
  Darwin)
    ;;
  Linux)
    GEANT4_ARGS="${GEANT4_ARGS} -DGEANT4_USE_SYSTEM_EXPAT:BOOL=OFF"
    ;;
esac

GEANT4_ARGS="${GEANT4_ARGS} -DGEANT4_USE_GDML:BOOL=ON -DXERCESC_ROOT_DIR:PATH='$CONTRIB_DIR/xercesc'"

######################################################################
#
# Add to path
#
######################################################################

#addtopathvar PATH $CONTRIB_DIR/geant4/bin

######################################################################
#
# Launch geant4 builds.
#
######################################################################

buildGeant4() {
  if bilderUnpack geant4; then
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
}


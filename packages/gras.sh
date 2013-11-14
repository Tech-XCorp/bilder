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

#addtopathvar PATH $CONTRIB_DIR/gras/bin

######################################################################
#
# Launch gras builds.
#
######################################################################

buildGras() {
  GRAS_SER_INSTALL_DIR=$CONTRIB_DIR
  GRAS_SER_BUILD_DIR=$BUILD_DIR/gras-$GRAS_BLDRVERSION/ser
  G4INSTALL="$CONTRIB_DIR/geant4"
  GRAS_ENV="$GRAS_ENV G4INSTALL='$G4INSTALL'"
  export G4INSTALL
  #source $G4INSTALL/bin/geant4.sh
  if bilderUnpack gras; then
    if bilderConfig -c gras ser "-DXERCESC_ROOT_DIR:PATH='$CONTRIB_DIR/xercesc' $CMAKE_SUPRA_SP_ARG"; then
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
  bilderInstall gras ser
}


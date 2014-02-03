#!/bin/bash
#
# Version and build information for mulassis
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MULASSIS_BLDRVERSION=${MULASSIS_BLDRVERSION:-"1.21"}

######################################################################
#
# Other values
#
######################################################################

MULASSIS_BUILDS=${MULASSIS_BUILDS:-"ser"}
MULASSIS_DEPS=geant4,pcre

######################################################################
#
# Add to path
#
######################################################################

#addtopathvar PATH $CONTRIB_DIR/mulassis/bin

######################################################################
#
# Launch mulassis builds.
#
######################################################################

buildMulassis() {
  MULASSIS_CONFIG_METHOD=none
  MULASSIS_SER_INSTALL_DIR=$CONTRIB_DIR
  MULASSIS_SER_BUILD_DIR=$BUILD_DIR/mulassis-$MULASSIS_BLDRVERSION/ser
  G4INSTALL="$CONTRIB_DIR/geant4"
  MULASSIS_ENV="$MULASSIS_ENV G4INSTALL='$G4INSTALL'"
  export G4INSTALL
  if bilderUnpack -i mulassis; then
  bilderBuild mulassis ser "" "$MULASSIS_ENV"
  fi
}

######################################################################
#
# Test mulassis
#
######################################################################

testMulassis() {
  techo "Not testing mulassis."
}

######################################################################
#
# Install mulassis
#
######################################################################

installMulassis() {
  bilderInstall mulassis ser
}


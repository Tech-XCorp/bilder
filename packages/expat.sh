#!/bin/bash
#
# Version and build information for Expat
#
# $Id: expat.sh 290 2013-07-18 18:06:28Z swsides $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Version
EXPAT_BLDRVERSION=${EXPAT_BLDRVERSION:-"2.1.0"}

######################################################################
#
# Builds
#
######################################################################

EXPAT_BUILDS=${EXPAT_BUILDS:-"ser"}
#EXPAT_DEPS=fftw3,boost,gsl
######################################################################


######################################################################
#
# Launch expat builds.
#
######################################################################
buildExpat() {

  # Setting args
  EXPAT_ARGS= "$EXPAT_ARGS $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS"

  if bilderUnpack expat; then

    # Serial build
    if bilderConfig expat ser "$EXPAT_ARGS"; then
      bilderBuild expat ser "$EXPAT_MAKEJ_ARGS"
    fi

  fi
}

######################################################################
#
# Test expat
#
######################################################################

testExpat() {
  techo "Not testing expat."
}

######################################################################
#
# Install expat
#
######################################################################

installExpat() {
  bilderInstall expat ser expat
}



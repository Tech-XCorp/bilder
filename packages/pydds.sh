#!/bin/bash
#
# Version and build information for pydds
#
# $Id: pydds.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PYDDS_BLDRVERSION=${PYDDS_BLDRVERSION:-""}

# Built from package only
######################################################################
#
# Other values
#
######################################################################

PYDDS_BUILDS=${PYDDS_BUILDS:-"ser"}
PYDDS_DEPS=cmake,Python,boost,opensplice
PYDDS_UMASK=002

######################################################################
#
# Launch pydds builds
#
######################################################################

buildPydds() {
  if bilderConfig -c pydds ser; then
    bilderBuild pydds ser
  fi
}

######################################################################
#
# Test pydds must be driven from top level qdstests 
#
######################################################################
testPydds() {
  techo "No tests yet"
}

######################################################################
#
# Install pydds
#
######################################################################

installPydds() {
  bilderInstall pydds ser
}

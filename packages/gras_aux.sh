#!/bin/bash
#
# Version and find information for gras
#
# $Id$
#
######################################################################

getGrasVersion() {
  GRAS_BLDRVERSION=${GRAS_BLDRVERSION:-"03-03-r1561"}
}
getGrasVersion

######################################################################
#
# Find gras
#
######################################################################

# Find the directory containing the gras cmake files
findGras() {

# Look for Gras in the contrib directory
  findContribPackage Gras G4global sersh cc4py
  findCc4pyDir Gras

# Set envvars for other packages
  local GRAS_HOME="$CONTRIB_DIR/gras-sersh"
  printvar GRAS_HOME
  source $GRAS_HOME/bin/gras-env.sh

}

#
# Find Gras at time of sourcing, as installGras may be called
# if builds disabled
#
findGras


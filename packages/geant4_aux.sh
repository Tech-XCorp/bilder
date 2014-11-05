#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

setGeant4TriggerVars() {
# Version 10 does not work with gras-03-03-r1561
  # GEANT4_BLDRVERSION=${GEANT4_BLDRVERSION:-"10.00.p01"}
  # GEANT4_BLDRVERSION=${GEANT4_BLDRVERSION:-"9.6.p02"}
# Make sure to repack to Bilder conventions:
#  tar xzf geant4-9.6.p03.tar.gz
#  mv geant4.9.6.p03 geant4-9.6.p03
#  tar czf geant4-9.6.p03.tar.gz  geant4-9.6.p03
# and then add the above tarball to svnpkgs
# p03 is recommended for GRAS
  GEANT4_BLDRVERSION=${GEANT4_BLDRVERSION:-"9.6.p03"}
  GEANT4_BUILDS=${GEANT4_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  GEANT4_DEPS=qt,pcre,xercesc,cmake
  trimvar GEANT4_DEPS ,
}
setGeant4TriggerVars

######################################################################
#
# Find geant4
#
######################################################################

# Set variables to help find geant4
findGeant4() {

# Look for Geant4 in the contrib directory
  findContribPackage Geant4 G4global sersh pycsh
  findCc4pyDir Geant4

# Environment variables to help find Geant4
  local GEANT4_HOME="$CONTRIB_DIR/geant4-sersh"
  GEANT4_HOME=`(cd $GEANT4_HOME; pwd -P)`
  local GEANT4_REGVER=`echo $GEANT4_BLDRVERSION | sed -e 's/\.p0*/./' -e 's/\.00*\./.0./' -e 's/\.00*/.0/'`
  export G4DATA="$GEANT4_HOME/share/Geant4-${GEANT4_REGVER}/data"
  export G4LEDATA="$G4DATA/G4EMLOW6.32"
  export G4LEVELGAMMADATA="$G4DATA/PhotonEvaporation2.3"
  export G4NEUTRONXSDATA="$G4DATA/G4NEUTRONXS1.2"
  export G4SAIDXSDATA="$G4DATA/G4SAIDDATA1.1"
  export GEANT4_SERSH_CMAKE_DIR=$GEANT4_HOME/lib/Geant4-${GEANT4_REGVER}
  for i in G4DATA G4LEDATA G4LEVELGAMMADATA G4NEUTRONXSDATA G4SAIDXSDATA GEANT4_SERSH_CMAKE_DIR; do
    printvar $i
  done

# The following lines introduce new env vars such as G4INSTALL, G4INCLUDE etc.
# Do these work for cmake projects?
#  source $GEANT4_HOME/bin/geant4.sh
#  source $GEANT4_HOME/share/Geant4-${GEANT4_REGVER}/geant4make/geant4make.sh

# Add to path
  addtopathvar PATH $CONTRIB_DIR/geant4-$FORPYTHON_SHARED_BUILD/bin

}


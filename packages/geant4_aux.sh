#!/bin/bash
#
# Version and find information for geant4
#
# $Id$
#
######################################################################

getGeant4Version() {
  GEANT4_BLDRVERSION=${GEANT4_BLDRVERSION:-"10.00.p01"}
}
getGeant4Version

######################################################################
#
# Find geant4
#
######################################################################

# Find the directory containing the OCE cmake files
findGeant4() {

# Look for Geant4 in the contrib directory
  findContribPackage Geant4 TKMath sersh cc4py
  findCc4pyDir Geant4

# Environment variables to help find Geant4
  local GEANT4_HOME="$CONTRIB_DIR/geant4-sersh"
  GEANT4_HOME=`(cd $GEANT4_HOME; pwd -P)`
  GEANT4_REGVER=`echo $GEANT4_BLDRVERSION | sed -e 's/\.p0*/./' -e 's/\.00*\./.0./' -e 's/\.00*/.0/'`
  export G4DATA="$GEANT4_HOME/share/Geant4-${GEANT4_REGVER}/data"
  export G4LEDATA="$G4DATA/G4EMLOW6.32"
  export G4LEVELGAMMADATA="$G4DATA/PhotonEvaporation2.3"
  export G4NEUTRONXSDATA="$G4DATA/G4NEUTRONXS1.2"
  export G4SAIDXSDATA="$G4DATA/G4SAIDDATA1.1"

# The following lines introduce new env vars such as
# G4INSTALL, G4INCLUDE etc.  Not sure if we use them as they are not cmake.
#  source $GEANT4_HOME/bin/geant4.sh
#  source $GEANT4_HOME/share/Geant4-9.6.2/geant4make/geant4make.sh

}


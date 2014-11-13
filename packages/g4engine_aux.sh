#!/bin/bash
#
# Trigger vars and find information
#
# $Id: g4engine_aux.sh 1840 2014-11-05 09:59:48Z jrobcary $
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setG4engineTriggerVars() {
  G4ENGINE_BUILDS=${G4ENGINE_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  G4ENGINE_DEPS=geant4,moab
#  G4ENGINE_DEPS=geant4,moab,boost,pyne,pytaps, 
}
setG4engineTriggerVars

######################################################################
#
# Find g4engine
#
######################################################################

# Compute vars that help to find g4engine
findG4engine() {
# Look for G4engine in the contrib directory
  findPackage G4engine dagsolid "$BLDR_INSTALL_DIR" pycsh sersh
  findPycshDir G4engine
}


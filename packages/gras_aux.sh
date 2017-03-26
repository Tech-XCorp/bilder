#!/bin/sh
######################################################################
#
# @file    gras_aux.sh
#
# @brief   Trigger vars and find information for gras.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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

setGrasTriggerVars() {
  GRAS_BLDRVERSION=${GRAS_BLDRVERSION:-"03-04"}
  if test -z "$GRAS_BUILDS"; then
    GRAS_BUILDS="ser"
  fi
  GRAS_DEPS=geant4
}
setGrasTriggerVars

######################################################################
#
# Find gras
#
######################################################################

# Find the directory containing the gras cmake files
findGras() {

# Look for Gras in the contrib directory
  findContribPackage Gras G4global ser
  findPycshDir Gras

# Set envvars for other packages
  local GRAS_HOME="$CONTRIB_DIR/gras-ser"
  printvar GRAS_HOME
  source $GRAS_HOME/bin/gras-env.sh
  addtopathvar PATH $CONTRIB_DIR/gras-ser/bin

}


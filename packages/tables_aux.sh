#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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

setTablesTriggerVars() {
  TABLES_BLDRVERSION_STD=${TABLES_BLDRVERSION_STD:-"3.1.1"}
  TABLES_BLDRVERSION_EXP=${TABLES_BLDRVERSION_EXP:-"3.2.0"}
  computeVersion tables
  TABLES_BUILDS=${TABLES_BUILDS:-"pycsh"}
  TABLES_DEPS=hdf5,Cython,numexpr,numpy
}
setTablesTriggerVars

######################################################################
#
# Find numexpr
#
######################################################################

findTables() {
  :
}
findTables


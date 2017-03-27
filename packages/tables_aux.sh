#!/bin/sh
######################################################################
#
# @file    tables_aux.sh
#
# @brief   Trigger vars and find information for tables.
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

setTablesTriggerVars() {
  TABLES_BLDRVERSION_STD=${TABLES_BLDRVERSION_STD:-"3.3.0"}
  TABLES_BLDRVERSION_EXP=${TABLES_BLDRVERSION_EXP:-"3.3.0"}
  computeVersion tables
  TABLES_BUILDS=${TABLES_BUILDS:-"pycsh"}
  TABLES_DEPS=hdf5,Cython,numexpr,numpy,six
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


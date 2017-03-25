#!/bin/sh
######################################################################
#
# @file    metatau_aux.sh
#
# @brief   Trigger vars and find information for metatau.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
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

setMetatauTriggerVars() {
  METATAU_BLDRVERSION_STD=${METATAU_BLDRVERSION_STD:-"2.21.1"}
  METATAU_BLDRVERSION_EXP=${METATAU_BLDRVERSION_EXP:-"2.21.1"}
  METATAU_BUILDS=${METATAU_BUILDS:-"par"}
  METATAU_DEPS=$MPI_BUILD
}
setMetatauTriggerVars

######################################################################
#
# Find metatau
#
######################################################################

findMetatau() {
  addtopathvar PATH $CONTRIB_DIR/tau/bin
}


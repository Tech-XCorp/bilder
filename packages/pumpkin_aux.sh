#!/bin/sh
######################################################################
#
# @file    pumpkin_aux.sh
#
# @brief   Trigger vars and find information for pumpkin.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
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

setPumpkinTriggerVars() {
  PUMPKIN_BLDRVERSION=${PUMPKIN_BLDRVERSION:-"1.1.0"}
  PUMPKIN_BUILDS=${PUMPKIN_BUILDS:-"ser"}
  PUMPKIN_DEPS=glpk
}
setPumpkinTriggerVars

######################################################################
#
# Find pumpkin
#
######################################################################

findPumpkin() {
  :
}


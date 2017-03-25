#!/bin/sh
######################################################################
#
# @file    pyside_aux.sh
#
# @brief   Trigger vars and find information for pyside.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
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

setPySideTriggerVars() {
  PYSIDE_BLDRVERSION_STD=${PYSIDE_BLDRVERSION_STD:-"1.2.4"}
  PYSIDE_BLDRVERSION_EXP=${PYSIDE_BLDRVERSION_EXP:-"1.2.4"}
  PYSIDE_BUILDS=pycsh
  PYSIDE_DEPS=shiboken
}
setPySideTriggerVars

######################################################################
#
# Find pyside
#
######################################################################

findPySide() {
  :
}


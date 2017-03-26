#!/bin/sh
######################################################################
#
# @file    pyparsing_aux.sh
#
# @brief   Trigger vars and find information for pyparsing.
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

setPyparsingTriggerVars() {
  PYPARSING_BLDRVERSION_STD=${PYPARSING_BLDRVERSION_STD:-"2.1.10"}
  PYPARSING_BLDRVERSION_EXP=${PYPARSING_BLDRVERSION_EXP:-"2.1.10"}
  PYPARSING_BUILDS=${PYPARSING_BUILDS:-"pycsh"}
  PYPARSING_DEPS=setuptools,Python
}
setPyparsingTriggerVars

######################################################################
#
# Find pyparsing
#
######################################################################

findPyparsing() {
  :
}


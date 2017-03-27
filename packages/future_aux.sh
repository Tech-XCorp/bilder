#!/bin/sh
######################################################################
#
# @file    future_aux.sh
#
# @brief   Trigger vars and find information for the future python module.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
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

setFutureTriggerVars() {
  FUTURE_BLDRVERSION_STD=0.16.0
  FUTURE_BLDRVERSION_EXP=0.16.0
  FUTURE_BUILDS=${EMPY_BUILDS:-"pycsh"}
  FUTURE_DEPS=setuptools,Python
}
setFutureTriggerVars

######################################################################
#
# Find future
#
######################################################################

findFuture() {
  :
}
findFuture


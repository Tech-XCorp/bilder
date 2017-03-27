#!/bin/sh
######################################################################
#
# @file    pygments_aux.sh
#
# @brief   Trigger vars and find information for pygments.
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

setPygmentsTriggerVars() {
  PYGMENTS_BLDRVERSION_STD=${PYGMENTS_BLDRVERSION_STD:-"2.1.3"}
  PYGMENTS_BLDRVERSION_EXP=${PYGMENTS_BLDRVERSION_EXP:-"2.1.3"}
  PYGMENTS_BUILDS=${PYGMENTS_BUILDS:-"pycsh"}
  PYGMENTS_DEPS=setuptools,Python
}
setPygmentsTriggerVars

######################################################################
#
# Find pygments
#
######################################################################

findPygments() {
  :
}


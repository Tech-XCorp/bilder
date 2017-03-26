#!/bin/sh
######################################################################
#
# @file    sortedcontainers_aux.sh
#
# @brief   Trigger vars and find information for sortedcontainers.
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

setSortedContainersTriggerVars() {
  SORTEDCONTAINERS_BLDRVERSION_STD=${SORTEDCONTAINERS_BLDRVERSION_STD:-"1.5.3"}
  SORTEDCONTAINERS_BLDRVERSION_EXP=${SORTEDCONTAINERS_BLDRVERSION_EXP:-"1.5.3"}
  SORTEDCONTAINERS_BUILDS=${SORTEDCONTAINERS_BUILDS:-"pycsh"}
  SORTEDCONTAINERS_DEPS=Python
}
setSortedContainersTriggerVars

######################################################################
#
# Find sortedcontainers
#
######################################################################

findSortedContainers() {
  :
}


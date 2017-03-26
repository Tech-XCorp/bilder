#!/bin/sh
######################################################################
#
# @file    requests_aux.sh
#
# @brief   Trigger vars and find information.
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

setRequestsTriggerVars() {
  REQUESTS_BLDRVERSION=${REQUESTS_BLDRVERSION:-"2.12.4"}
  REQUESTS_BUILDS=${REQUESTS_BUILDS:-"pycsh"}
  REQUESTS_DEPS=
}
setRequestsTriggerVars

######################################################################
#
# Find xz
#
######################################################################

findRequests() {
  :
}


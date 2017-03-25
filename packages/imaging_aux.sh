#!/bin/sh
######################################################################
#
# @file    imaging_aux.sh
#
# @brief   Trigger vars and find information for imaging.
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

setImagingTriggerVars() {
  IMAGING_BLDRVERSION=${IMAGING_BLDRVERSION:-"1.1.7"}
  IMAGING_BUILDS=${IMAGING_BUILDS:-"pycsh"}
  IMAGING_DEPS=Python
}
setImagingTriggerVars

######################################################################
#
# Find imaging
#
######################################################################

findImaging() {
  :
}


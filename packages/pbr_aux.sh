#!/bin/sh
######################################################################
#
# @file    pbr_aux.sh
#
# @brief   Trigger vars and find information for pbr.
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

setPbrTriggerVars() {
  PBR_BLDRVERSION_STD=${PBR_BLDRVERSION_STD:-"1.10.0"}
  PBR_BLDRVERSION_EXP=${PBR_BLDRVERSION_EXP:-"1.10.0"}
  PBR_BUILDS=${PBR_BUILDS:-"pycsh"}
  PBR_DEPS=imagesize,setuptools,Python
}
setPbrTriggerVars

######################################################################
#
# Find pbr
#
######################################################################

findPbr() {
  :
}


#!/bin/sh
######################################################################
#
# @file    six_aux.sh
#
# @brief   Trigger vars and find information for six.
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

setSixTriggerVars() {
  SIX_BLDRVERSION_STD=${SIX_BLDRVERSION_STD:-"1.10.0"}
  SIX_BLDRVERSION_EXP=${SIX_BLDRVERSION_EXP:-"1.10.0"}
  SIX_BUILDS=${SIX_BUILDS:-"pycsh"}
  SIX_DEPS=Python
}
setSixTriggerVars

######################################################################
#
# Find six
#
######################################################################

findSix() {
  :
}


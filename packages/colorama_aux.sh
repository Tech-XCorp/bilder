#!/bin/sh
######################################################################
#
# @file    colorama_aux.sh
#
# @brief   Trigger vars and find information for colorama.
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

setColoramaTriggerVars() {
  COLORAMA_BLDRVERSION_STD=${COLORAMA_BLDRVERSION_STD:-"0.3.7"}
  COLORAMA_BLDRVERSION_EXP=${COLORAMA_BLDRVERSION_EXP:-"0.3.7"}
  COLORAMA_BUILDS=${COLORAMA_BUILDS:-"pycsh"}
  COLORAMA_DEPS=Python
}
setColoramaTriggerVars

######################################################################
#
# Find colorama
#
######################################################################

findColorama() {
  :
}


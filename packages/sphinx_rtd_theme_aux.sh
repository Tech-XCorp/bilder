#!/bin/sh
######################################################################
#
# @file    sphinx_rtd_theme_aux.sh
#
# @brief   Trigger vars and find information for sphinx_rtd_theme.
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

setSphinx_rtd_themeTriggerVars() {
  SPHINX_RTD_THEME_BLDRVERSION_STD=${SPHINX_RTD_THEME_BLDRVERSION_STD:-"0.1.10a0"}
  SPHINX_RTD_THEME_BLDRVERSION_EXP=${SPHINX_RTD_THEME_BLDRVERSION_EXP:-"0.1.10a0"}
  SPHINX_RTD_THEME_BUILDS=${SPHINX_RTD_THEME_BUILDS:-"pycsh"}
  SPHINX_RTD_THEME_DEPS=Python
}
setSphinx_rtd_themeTriggerVars

######################################################################
#
# Find sphinx_rtd_theme
#
######################################################################

findSphinx_rtd_theme() {
  :
}


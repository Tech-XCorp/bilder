#!/bin/sh
######################################################################
#
# @file    sphinx_bootstrap_theme_aux.sh
#
# @brief   Trigger vars and find information for sphinx_bootstrap_theme.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# tar xzf sphinx-bootstrap-theme-0.4.13.tar.gz
# mv sphinx-bootstrap-theme-0.4.13 sphinx_bootstrap_theme-0.4.13
# env COPYFILE_DISABLE=true tar czf sphinx_bootstrap_theme-0.4.13.tgz sphinx_bootstrap_theme-0.4.13
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

setSphinx_bootstrap_themeTriggerVars() {
  SPHINX_BOOTSTRAP_THEME_BLDRVERSION_STD=${SPHINX_BOOTSTRAP_THEME_BLDRVERSION_STD:-"0.4.13"}
  SPHINX_BOOTSTRAP_THEME_BLDRVERSION_EXP=${SPHINX_BOOTSTRAP_THEME_BLDRVERSION_EXP:-"0.4.13"}
  SPHINX_BOOTSTRAP_THEME_BUILDS=${SPHINX_BOOTSTRAP_THEME_BUILDS:-"pycsh"}
  SPHINX_BOOTSTRAP_THEME_DEPS=Python
}
setSphinx_bootstrap_themeTriggerVars

######################################################################
#
# Find sphinx_bootstrap_theme
#
######################################################################

findSphinx_bootstrap_theme() {
  :
}


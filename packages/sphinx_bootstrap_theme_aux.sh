#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
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
  SPHINX_BOOTSTRAP_THEME_BLDRVERSION_STD=${SPHINX_BOOTSTRAP_THEME_BLDRVERSION_STD:-"0.4.7"}
  SPHINX_BOOTSTRAP_THEME_BLDRVERSION_EXP=${SPHINX_BOOTSTRAP_THEME_BLDRVERSION_EXP:-"0.4.7"}
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


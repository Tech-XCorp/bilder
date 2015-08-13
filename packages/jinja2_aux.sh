#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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

setJinja2TriggerVars() {
  JINJA2_BLDRVERSION_STD=${JINJA2_BLDRVERSION_STD:-"2.7.3"}
  JINJA2_BLDRVERSION_EXP=${JINJA2_BLDRVERSION_EXP:-"2.7.3"}
  JINJA2_BUILDS=${JINJA2_BUILDS:-"pycsh"}
  JINJA2_DEPS=markupsafe,setuptools,Python
}
setJinja2TriggerVars

######################################################################
#
# Find jinja2
#
######################################################################

findJinja2() {
  :
}


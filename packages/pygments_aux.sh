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

setPygmentsTriggerVars() {
  PYGMENTS_BLDRVERSION_STD=${PYGMENTS_BLDRVERSION_STD:-"2.1.3"}
  PYGMENTS_BLDRVERSION_EXP=${PYGMENTS_BLDRVERSION_EXP:-"2.1.3"}
  PYGMENTS_BUILDS=${PYGMENTS_BUILDS:-"pycsh"}
  PYGMENTS_DEPS=setuptools,Python
}
setPygmentsTriggerVars

######################################################################
#
# Find pygments
#
######################################################################

findPygments() {
  :
}


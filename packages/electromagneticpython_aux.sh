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

setElectroMagneticPythonTriggerVars() {
  ELECTROMAGNETICPYTHON_BLDRVERSION_STD=1.2.0.1
  ELECTROMAGNETICPYTHON_BLDRVERSION_EXP=1.2.0.1
  ELECTROMAGNETICPYTHON_BUILDS=${ELECTROMAGNETICPYTHON_BUILDS:-"pycsh"}
  ELECTROMAGNETICPYTHON_DEPS=scipy,numpy,future,setuptools,Python
}
setElectroMagneticPythonTriggerVars

######################################################################
#
# Find ElectroMagneticPython
#
######################################################################

findElectroMagneticPython() {
  :
}


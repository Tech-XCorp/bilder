#!/bin/bash
#
# Build information for ElectroMagneticPython Python module.
#
#    see http://lbolla.github.io/ElectroMagneticPython
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in ElectroMagneticPython_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/electromagneticpython_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setElectroMagneticPythonNonTriggerVars() {
  :
}
setElectroMagneticPythonNonTriggerVars

######################################################################
#
# Launch ElectroMagneticPython builds.
#
######################################################################

buildElectroMagneticPython() {

# Get ElectroMagneticPython
  if ! bilderUnpack ElectroMagneticPython; then
    return
  fi

  ELECTROMAGNETICPYTHON_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/ElectroMagneticPython.files'"
  bilderDuBuild -p EMpy ElectroMagneticPython "$ELECTROMAGNETICPYTHON_ARGS"

}

######################################################################
#
# Test ElectroMagneticPython
#
######################################################################

testElectroMagneticPython() {
  techo "Not testing ElectroMagneticPython."
}

######################################################################
#
# Install ElectroMagneticPython
#
######################################################################

installElectroMagneticPython() {
  bilderDuInstall ElectroMagneticPython "$ELECTROMAGNETICPYTHON_INSTALL_ARGS"
}


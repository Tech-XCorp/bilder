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

setMatplotlibTriggerVars() {
  MATPLOTLIB_BLDRVERSION_STD=${MATPLOTLIB_BLDRVERSION_STD:-"1.4.3"}
  MATPLOTLIB_BLDRVERSION_EXP=${MATPLOTLIB_BLDRVERSION_EXP:-"1.5.3"}
  MATPLOTLIB_BUILDS=${MATPLOTLIB_BUILDS:-"pycsh"}
# Dependencies listed in matplotlib-1.4.3-py2.7.egg-info/requires.txt
  MATPLOTLIB_DEPS=numpy,libpng,freetype,Python
  MATPLOTLIB_DEPS=python_dateutil,mock,nose,pyparsing,pytz,six,$MATPLOTLIB_DEPS
# Additional seen to be installed
  MATPLOTLIB_DEPS=markupsafe,pbr,$MATPLOTLIB_DEPS
# Adding pyqt to the chain is causing long build times, so removing.
# Those who need it should add it to the target.
}
setMatplotlibTriggerVars

######################################################################
#
# Find matplotlib
#
######################################################################

findMatplotlib() {
  :
}


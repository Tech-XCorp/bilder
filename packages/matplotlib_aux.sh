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
  MATPLOTLIB_BLDRVERSION_STD=${MATPLOTLIB_BLDRVERSION_STD:-"1.3.1"}
  MATPLOTLIB_BLDRVERSION_EXP=${MATPLOTLIB_BLDRVERSION_EXP:-"1.4.2"}
  MATPLOTLIB_BUILDS=${MATPLOTLIB_BUILDS:-"pycsh"}
  MATPLOTLIB_DEPS=pyparsing,numpy,Python,libpng,freetype
  case `uname` in
    Darwin) ;;
    *) MATPLOTLIB_DEPS=pyqt,${MATPLOTLIB_DEPS};;
  esac
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


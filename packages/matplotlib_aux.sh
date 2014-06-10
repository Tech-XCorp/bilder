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
  MATPLOTLIB_BLDRVERSION_EXP=${MATPLOTLIB_BLDRVERSION_EXP:-"1.3.1"}
  MATPLOTLIB_BUILDS=${MATPLOTLIB_BUILDS:-"cc4py"}
  MATPLOTLIB_DEPS=numpy,Python,libpng,freetype
  case `uname` in
    Darwin) ;;
    *) MATPLOTLIB_DEPS=${MATPLOTLIB_DEPS},pyqt ;;
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


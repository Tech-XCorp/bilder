#!/bin/sh
######################################################################
#
# @file    xz_aux.sh
#
# @brief   Trigger vars and find information for xz.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
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

setXzTriggerVars() {
  XZ_BLDRVERSION_STD=${XZ_BLDRVERSION_STD:-"5.0.3"}
  XZ_BLDRVERSION_EXP=${XZ_BLDRVERSION_EXP:-"5.0.3"}
  XZ_BUILDS=${XZ_BUILDS:-"ser"}
# Removing this as creates a circular dependency through graphviz
  # XZ_DEPS=doxygen
}
setXzTriggerVars

######################################################################
#
# Find xz
#
######################################################################

findXz() {
  addtopathvar PATH $CONTRIB_DIR/xz/bin
}


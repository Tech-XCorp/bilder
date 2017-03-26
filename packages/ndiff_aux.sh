#!/bin/sh
######################################################################
#
# @file    ndiff_aux.sh
#
# @brief   Trigger vars and find information for ndiff.
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

setNdiffTriggerVars() {
  NDIFF_BLDRVERSION_STD=2.00
  NDIFF_BLDRVERSION_EXP=2.00
  NDIFF_BUILDS=pycsh
  NDIFF_DEPS=automake
}
setNdiffTriggerVars

######################################################################
#
# Find ndiff
#
######################################################################

findNdiff() {
    addtopathvar PATH $CONTRIB_DIR/ndiff/bin
    getCombinedCompVars
}


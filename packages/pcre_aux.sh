#!/bin/sh
######################################################################
#
# @file    pcre_aux.sh
#
# @brief   Trigger vars and find information for pcre.
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

setPcreTriggerVars() {
  PCRE_BLDRVERSION_STD=${PCRE_BLDRVERSION:-"8.36"}
  PCRE_BLDRVERSION_EXP=${PCRE_BLDRVERSION:-"8.36"}
  PCRE_BUILDS=${PCRE_BUILDS:-"ser"}
  PCRE_DEPS=cmake
}
setPcreTriggerVars

######################################################################
#
# Find swig
#
######################################################################

findPcre() {
  findPackage Pcre pcre "$CONTRIB_DIR" ser
  findPycstDir Pcre
  addtopathvar PATH $CONTRIB_DIR/pcre/bin
}


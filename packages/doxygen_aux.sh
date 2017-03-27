#!/bin/sh
######################################################################
#
# @file    doxygen_aux.sh
#
# @brief   Trigger vars and find information for doxygen.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
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

setDoxygenTriggerVars() {
  DOXYGEN_BLDRVERSION_STD=${DOXYGEN_BLDRVERSION_STD:-"1.8.13"}
  DOXYGEN_BLDRVERSION_EXP=${DOXYGEN_BLDRVERSION_EXP:-"1.8.13"}
  case `uname` in
    CYGWIN*) ;;
    *) DOXYGEN_BUILDS=${DOXYGEN_BUILDS:-"${FORPYTHON_STATIC_BUILD}"};;
  esac
  DOXYGEN_DEPS=cmake,graphviz
}
setDoxygenTriggerVars

######################################################################
#
# Find doxygen
#
######################################################################

findDoxygen() {
  :
}


#!/bin/sh
######################################################################
#
# @file    checker_aux.sh
#
# @brief   Trigger vars and find information for checker.
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

setCheckerTriggerVars() {
  CHECKER_BLDRVERSION_STD=${CHECKER_BLDRVERSION_STD="276"}
  CHECKER_BLDRVERSION_EXP=${CHECKER_BLDRVERSION_EXP="276"}
  if [[ $CC =~ clang ]]; then
    CHECKER_BUILDS=${CHECKER_BUILDS:-"ser"}
  fi
  CHECKER_DEPS=
}
setCheckerTriggerVars

######################################################################
#
# Find checker
#
######################################################################

findChecker() {
  addtopathvar PATH $CONTRIB_DIR/checker;
}


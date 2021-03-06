#!/bin/sh
######################################################################
#
# @file    cppcheck_aux.sh
#
# @brief   Trigger vars and find information for cppcheck.
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

setCppcheckTriggerVars() {
  CPPCHECK_BLDRVERSION_STD=${CPPCHECK_BLDRVERSION_STD:-"1.76.1"}
  CPPCHECK_BLDRVERSION_EXP=${CPPCHECK_BLDRVERSION_EXP:-"1.76.1"}
  if ! test "$CPPCHECK_BUILDS" = NONE; then
    if ! [[ `uname` =~ CYGWIN ]]; then
      if test -n "$GCC_MAJMIN"; then
        if test $GCC_MAJOR -lt 4 -o $GCC_MAJOR = 4 -a $GCC_MINOR -lt 3; then
          techo "WARNING: [$FUNCNAME] gcc version ($GCC_MAJMIN) insufficient to build cppcheck."
        else
          CPPCHECK_BUILDS=${CPPCHECK_BUILDS:-"ser"}
        fi
      else
        CPPCHECK_BUILDS=${CPPCHECK_BUILDS:-"ser"}
      fi
    fi
  fi
  CPPCHECK_DEPS=pcre
}
setCppcheckTriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

findCppcheck() {
  :
}


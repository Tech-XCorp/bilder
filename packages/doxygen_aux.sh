#!/bin/bash
#
# Trigger vars and find information
#
# $Id: zlib_aux.sh 1402 2014-05-19 16:56:22Z jrobcary $
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
  DOXYGEN_BLDRVERSION_STD=${DOXYGEN_BLDRVERSION_STD:-"1.8.5"}
  DOXYGEN_BLDRVERSION_EXP=${DOXYGEN_BLDRVERSION_EXP:-"1.8.5"}
  case `uname` in
    CYGWIN*) ;;
    *) DOXYGEN_BUILDS=${DOXYGEN_BUILDS:-"ser"};;
  esac
  DOXYGEN_DEPS=
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


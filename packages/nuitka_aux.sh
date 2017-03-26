#!/bin/sh
######################################################################
#
# @file    nuitka_aux.sh
#
# @brief   Trigger vars and find information for nuitka.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
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

setNuitkaTriggerVars() {
  NUITKA_BLDRVERSION_STD=${NUITKA_BLDRVERSION_STD="0.5.21.3"}
  NUITKA_BLDRVERSION_EXP=${NUITKA_BLDRVERSION_EXP="0.5.21.3"}
  NUITKA_BUILDS=${NUITKA_BUILDS:-"pycsh"}
  NUITKA_DEPS=Python
}
setNuitkaTriggerVars

######################################################################
#
# Find nuitka
#
######################################################################

findNuitka() {
  case `uname` in
    CYGWIN*) addtopathvar PATH $CONTRIB_DIR/Scripts;;
          *) addtopathvar PATH $CONTRIB_DIR/bin;;
  esac
}


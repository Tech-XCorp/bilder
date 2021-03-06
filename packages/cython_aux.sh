#!/bin/sh
######################################################################
#
# @file    cython_aux.sh
#
# @brief   Trigger vars and find information for cython.
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

setCythonTriggerVars() {
  CYTHON_BLDRVERSION_STD=0.25.2
  CYTHON_BLDRVERSION_EXP=0.25.2
  CYTHON_BUILDS=${CYTHON_BUILDS:-"pycsh"}
  CYTHON_DEPS=setuptools,Python
  if $HAVE_ATLAS_PYC; then
    CYTHON_DEPS="$CYTHON_DEPS,atlas"
  fi
}
setCythonTriggerVars

######################################################################
#
# Find cython
#
######################################################################

findCython() {
  :
}
findCython


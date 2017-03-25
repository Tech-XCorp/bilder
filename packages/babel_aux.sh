#!/bin/sh
######################################################################
#
# @file    babel_aux.sh
#
# @brief   Trigger vars and find information for babel.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
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

setBabelTriggerVars() {
  BABEL_BLDRVERSION_STD=${BABEL_BLDRVERSION_STD:-"2.3.4"}
  BABEL_BLDRVERSION_EXP=${BABEL_BLDRVERSION_EXP:-"2.3.4"}
  BABEL_BUILDS=${BABEL_BUILDS:-"pycsh"}
  BABEL_DEPS=pytz,setuptools,Python
}
setBabelTriggerVars

######################################################################
#
# Find babel
#
######################################################################

findBabel() {
  :
}


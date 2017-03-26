#!/bin/sh
######################################################################
#
# @file    pytz_aux.sh
#
# @brief   Trigger vars and find information for pytz.
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

setPytzTriggerVars() {
  PYTZ_BLDRVERSION_STD=${PYTZ_BLDRVERSION_STD:-"2016.10"}
  PYTZ_BLDRVERSION_EXP=${PYTZ_BLDRVERSION_EXP:-"2016.10"}
  PYTZ_BUILDS=${PYTZ_BUILDS:-"pycsh"}
  PYTZ_DEPS=Python
}
setPytzTriggerVars

######################################################################
#
# Find pytz
#
######################################################################

findPytz() {
  :
}


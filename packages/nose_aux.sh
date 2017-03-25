#!/bin/sh
######################################################################
#
# @file    nose_aux.sh
#
# @brief   Trigger vars and find information for nose.
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

setNoseTriggerVars() {
  NOSE_BLDRVERSION_STD=${NOSE_BLDRVERSION_STD:-"1.3.7"}
  NOSE_BLDRVERSION_EXP=${NOSE_BLDRVERSION_EXP:-"1.3.7"}
  NOSE_BUILDS=${NOSE_BUILDS:-"pycsh"}
  NOSE_DEPS=setuptools,Python
}
setNoseTriggerVars

######################################################################
#
# Find nose
#
######################################################################

findNose() {
  :
}


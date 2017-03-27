#!/bin/sh
######################################################################
#
# @file    python_dateutil_aux.sh
#
# @brief   Trigger vars and find information for python_dateutil.
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

setPython_dateutilTriggerVars() {
  PYTHON_DATEUTIL_BLDRVERSION_STD=${PYTHON_DATEUTIL_BLDRVERSION_STD:-"2.4.2"}
  PYTHON_DATEUTIL_BLDRVERSION_EXP=${PYTHON_DATEUTIL_BLDRVERSION_EXP:-"2.4.2"}
  PYTHON_DATEUTIL_BUILDS=${PYTHON_DATEUTIL_BUILDS:-"pycsh"}
  PYTHON_DATEUTIL_DEPS=setuptools,Python
}
setPython_dateutilTriggerVars

######################################################################
#
# Find python_dateutil
#
######################################################################

findPython_dateutil() {
  :
}


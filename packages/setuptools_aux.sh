#!/bin/sh
######################################################################
#
# @file    setuptools_aux.sh
#
# @brief   Trigger vars and find information for setuptools.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# setuptools-18.0.1 installs
# _markerlib
# easy_install.py
# easy_install.pyc
# pkg_resources
# setuptools
# setuptools-18.0.1-py2.7.egg-info
# setuptools-record
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

setSetuptoolsTriggerVars() {
  SETUPTOOLS_BLDRVERSION_STD=${SETUPTOOLS_BLDRVERSION_STD:-"32.3.1"}
  SETUPTOOLS_BLDRVERSION_EXP=${SETUPTOOLS_BLDRVERSION_EXP:-"32.3.1"}
  SETUPTOOLS_BUILDS=${SETUPTOOLS_BUILDS:-"pycsh"}
  SETUPTOOLS_DEPS=Python
}
setSetuptoolsTriggerVars

######################################################################
#
# Find setuptools
#
######################################################################

findSetuptools() {
  :
}


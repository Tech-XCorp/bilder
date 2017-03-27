#!/bin/sh
######################################################################
#
# @file    libtool_aux.sh
#
# @brief   Trigger vars and find information for libtool.
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

setLibtoolTriggerVars() {
  LIBTOOL_BLDRVERSION_STD=${LIBTOOL_BLDRVERSION_STD:-"2.4.2"}
  LIBTOOL_BLDRVERSION_EXP=${LIBTOOL_BLDRVERSION_EXP:-"2.4.2"}
  computeVersion libtool
  LIBTOOL_BUILDS=${LIBTOOL_BUILDS:-"ser"}
  LIBTOOL_DEPS=automake
}
setLibtoolTriggerVars

######################################################################
#
# Find libtool
#
######################################################################

findLibtool() {
  addtopathvar PATH $CONTRIB_DIR/autotools/bin
}


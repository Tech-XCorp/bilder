#!/bin/sh
######################################################################
#
# @file    autoconf_aux.sh
#
# @brief   Trigger vars and find information for autoconf.
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

setAutoconfTriggerVars() {
  AUTOCONF_BLDRVERSION_STD=${AUTOCONF_BLDRVERSION_STD:-"2.69"}
  AUTOCONF_BLDRVERSION_EXP=${AUTOCONF_BLDRVERSION_EXP:-"2.69"}
  AUTOCONF_BUILDS=${AUTOCONF_BUILDS:-"ser"}
  AUTOCONF_DEPS=m4,xz
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
}
setAutoconfTriggerVars

######################################################################
#
# Find autoconf
#
######################################################################

findAutoconf() {
  addtopathvar PATH $CONTRIB_DIR/autotools/bin
}


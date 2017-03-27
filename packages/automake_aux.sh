#!/bin/sh
######################################################################
#
# @file    automake_aux.sh
#
# @brief   Trigger vars and find information for automake.
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

setAutomakeTriggerVars() {
  AUTOMAKE_BLDRVERSION_STD=${AUTOMAKE_BLDRVERSION_STD:-"1.14.1"}
  AUTOMAKE_BLDRVERSION_EXP=${AUTOMAKE_BLDRVERSION_EXP:-"1.14.1"}
# Fedora 20 has to have old automake
  if test -f /etc/redhat-release  && grep -q Fedora /etc/redhat-release; then
    fcnum=`sed -e 's/Fedora release *//' -e 's/ .*$//' </etc/redhat-release`
    if test $fcnum -ge 20; then
      AUTOMAKE_BLDRVERSION=${AUTOMAKE_BLDRVERSION:-"1.13.4"}
    fi
  fi
  AUTOMAKE_BUILDS=${AUTOMAKE_BUILDS:-"ser"}
  AUTOMAKE_DEPS=autoconf
# Libtool determines the installation prefix
  if test -z "$LIBTOOL_BLDRVERSION"; then
    source $BILDER_DIR/packages/libtool.sh
  fi
}
setAutomakeTriggerVars

######################################################################
#
# Find automake
#
######################################################################

findAutomake() {
  addtopathvar PATH $CONTRIB_DIR/autotools/bin
}


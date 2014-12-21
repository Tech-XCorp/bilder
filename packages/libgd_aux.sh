#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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

setLibgdTriggerVars() {
  LIBGD_BLDRVERSION_STD=${LIBGD_BLDRVERSION_STD:-"2.1.0"}
  LIBGD_BLDRVERSION_EXP=${LIBGD_BLDRVERSION_EXP:-"2.1.0"}
  if test -z "$LIBGD_BUILDS"; then
    LIBGD_BUILDS=ser
  fi
  LIBGD_DEPS=cmake
}
setLibgdTriggerVars

######################################################################
#
# Find libgd
#
######################################################################

findLibgd() {
  :
}


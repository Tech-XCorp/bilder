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

setHwlocTriggerVars() {
  HWLOC_BLDRVERSION_STD=${HWLOC_BLDRVERSION_STD:-"1.9.1"}
  HWLOC_BLDRVERSION_EXP=${HWLOC_BLDRVERSION_EXP:-"1.9.1"}
  if test -z "$HWLOC_BUILDS"; then
    case `uname` in
      CYGWIN*) ;;
      *) HWLOC_BUILDS="ser";;
    esac
  fi
  HWLOC_DEPS=autotools
}
setHwlocTriggerVars

######################################################################
#
# Find hwloc
#
######################################################################

findHwloc() {
  :
}


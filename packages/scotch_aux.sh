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

setScotchTriggerVars() {

  if test -z "$SCOTCH_BUILDS"; then
    SCOTCH_BUILDS=par
    case `uname` in
      CYGWIN*) ;;
      Darwin) SCOTCH_BUILDS="${SCOTCH_BUILDS}";;
      Linux) SCOTCH_BUILDS="${SCOTCH_BUILDS}";;
    esac
  fi
  SCOTCH_DEPS=autotools,$MPI_BUILD
}
setScotchTriggerVars

######################################################################
#
# Find scotch
#
######################################################################

findScotch() {
  :
}


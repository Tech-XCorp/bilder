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

setOpenmpiTriggerVars() {
  OPENMPI_BLDRVERSION_STD=1.6.5
  OPENMPI_BLDRVERSION_EXP=1.6.5
  if test -z "$OPENMPI_BUILDS"; then
    if $BUILD_MPIS; then
      case `uname` in
        CYGWIN*) OPENMPI_BUILDS=nodl ;;
        *) OPENMPI_BUILDS=nodl,static ;;
      esac
    fi
  fi
  OPENMPI_DEPS=valgrind,doxygen,libtool,automake
}
setOpenmpiTriggerVars

######################################################################
#
# Find oce
#
######################################################################

findOpenmpi() {
  addtopathvar PATH $CONTRIB_DIR/openmpi/bin
}


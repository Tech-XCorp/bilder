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

setBzip2TriggerVars() {
  BZIP2_BLDRVERSION=${BZIP2_BLDRVERSION:-"1.0.6"}
  if test -z "$BZIP2_BUILDS"; then
    if [[ `uname` =~ CYGWIN ]]; then
      BZIP2_BUILDS=ser
    fi
  fi
  BZIP2_DEPS=
  addtopathvar PATH $CONTRIB_DIR/bzip2/bin
}
setBzip2TriggerVars


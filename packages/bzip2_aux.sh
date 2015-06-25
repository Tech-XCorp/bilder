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
      # BZIP2_BUILDS=ser,sermd
      BZIP2_BUILDS=ser
    fi
  fi
  BZIP2_DEPS=
}
setBzip2TriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

findBzip2() {
  if [[ `uname` =~ CYGWIN ]]; then
    findContribPackage bzip2 bzip2 ser sermd
    findPycshDir bzip2
    addtopathvar PATH $CONTRIB_DIR/bzip2/bin
  fi
}


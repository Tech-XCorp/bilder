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

setMpichTriggerVars() {
  MPICH_BLDRVERSION_STD=3.0.4
  MPICH_BLDRVERSION_EXP=3.1.2
  MPICH_DEPS=libtool,automake
  if ! [[ `uname` =~ CYGWIN ]]; then
    MPICH_BUILDS=static,shared
  fi
}
setMpichTriggerVars

######################################################################
#
# Find mpich
#
######################################################################

findMpich() {
# Not adding for now to not conflict with openmpi
# addtopathvar PATH $CONTRIB_DIR/mpich/bin
  :
}


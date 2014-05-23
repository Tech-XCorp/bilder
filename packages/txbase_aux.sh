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

setTxbaseTriggerVars() {
  if test -z "$TXBASE_DESIRED_BUILDS"; then
    TXBASE_DESIRED_BUILDS=ser,par,sersh
    if [[ `uname` =~ CYGWIN ]]; then
      TXBASE_DESIRED_BUILDS="${TXBASE_DESIRED_BUILDS},sermd"
    fi
    if echo $DOCS_BUILDS | egrep -q "(^|,)develdocs($|,)"; then
      TXBASE_DESIRED_BUILDS=$TXBASE_DESIRED_BUILDS,develdocs
    fi
  fi
  computeBuilds txbase
  addCc4pyBuild txbase
  TXBASE_DEPS=hdf5,openmpi,boost,Python,cmake
}
setTxbaseTriggerVars

######################################################################
#
# Find txbase
#
######################################################################

findTxbase() {
  :
}


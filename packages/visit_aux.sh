#!/bin/bash
#
# Trigger vars and find information
#
# See http://portal.nersc.gov/svn/visit/branches/txc/README
# for the branch usage for Composer.
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

setVisItTriggerVars() {
  VISIT_BLDRVERSION=${VISIT_BLDRVERSION:-"2.6.0b"}
# VisIt is built the way python is built.
  if test -z "$VISIT_DESIRED_BUILDS"; then
    VISIT_DESIRED_BUILDS=$FORPYTHON_BUILD
    if isCcCc4py; then
      # if ! [[ `uname` =~ CYGWIN ]] && $BUILD_OPTIONAL; then
      if test `uname` = Linux  && $BUILD_OPTIONAL; then
        VISIT_DESIRED_BUILDS=$VISIT_DESIRED_BUILDS,parsh
      fi
    fi
  fi
  computeBuilds visit
  VISIT_SER_BUILD=$FORPYTHON_BUILD
  VISIT_DEPS=vtk,Imaging,numpy,Python,qt,hdf5,cmake
}
setVisItTriggerVars

######################################################################
#
# Find VisIt
#
######################################################################

findVisit() {
  :
}


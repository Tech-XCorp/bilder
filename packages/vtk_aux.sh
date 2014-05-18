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

getVtkTriggerVars() {
  VTK_BLDRVERSION=${VTK_BLDRVERSION:-"6.1.0"}
  VTK_BUILDS=${VTK_BUILDS:-"$FORPYTHON_BUILD"}
  VTK_BUILD=$FORPYTHON_BUILD
  VTK_DEPS=qt,cmake
}
getVtkTriggerVars

######################################################################
#
# Set paths and variables that change after a build
#
######################################################################

findVtk() {
  local majmin=`echo $VTK_BLDRVERSION | sed 's/\.[0-9]*$//'`
  techo -2 "Looking for vtkCommonCore-${majmin}."
  findContribPackage VTK vtkCommonCore-${majmin} sersh cc4py
  findCc4pyDir VTK
}


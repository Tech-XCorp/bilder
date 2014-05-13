#!/bin/bash
#
# Version and find information for vtk
#
# $Id$
#
######################################################################

######################################################################
#
# Version.
#
######################################################################

getVtkVersion() {
  VTK_BLDRVERSION=${VTK_BLDRVERSION:-"6.1.0"}
  VTK_NAME=${VTK_NAME:-"VTK"}  # Needed because of vtk -> VTK
}
getVtkVersion

######################################################################
#
# Find vtk
#
######################################################################

findVtk() {
  local majmin=`echo $VTK_BLDRVERSION | sed 's/\.[0-9]*$//'`
  techo -2 "Looking for vtkCommonCore-${majmin}."
  findContribPackage VTK vtkCommonCore-${majmin} sersh cc4py
  findCc4pyDir VTK
}

#
# Find Vtk at time of sourcing, as installVtk may be called
# if builds disabled
#
findVtk


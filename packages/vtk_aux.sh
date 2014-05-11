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
  findContribPackage VTK vtk sersh cc4py
  findCc4pyDir VTK
}


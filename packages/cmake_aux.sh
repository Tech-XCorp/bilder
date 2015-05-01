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

setCmakeTriggerVars() {
  local stdVersion="2.8.12.1"
  CMAKE_BLDRVERSION_STD=${CMAKE_BLDRVERSION_STD:-${stdVersion}}
  CMAKE_BLDRVERSION_EXP=${CMAKE_BLDRVERSION_EXP:-"3.2.2"}
  CMAKE_BUILDS=${CMAKE_BUILDS:-"ser"}
  CMAKE_DEPS=
}
setCmakeTriggerVars

######################################################################
#
# Find CMake
#
######################################################################

findCmake() {
  addtopathvar PATH $CONTRIB_DIR/cmake/bin
  CMAKE=`which cmake`
}


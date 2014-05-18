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

getCmakeTriggerVars() {
  CMAKE_BLDRVERSION_STD=${CMAKE_BLDRVERSION_STD:-"2.8.12.1"}
  CMAKE_BLDRVERSION_EXP=${CMAKE_BLDRVERSION_EXP:-"2.8.12.1"}
  CMAKE_BUILDS=${CMAKE_BUILDS:-"ser"}
  CMAKE_DEPS=
  addtopathvar PATH $CONTRIB_DIR/cmake/bin
}
getCmakeTriggerVars

######################################################################
#
# Find CMake
#
######################################################################

findCmake() {
  CMAKE=`which cmake`
}


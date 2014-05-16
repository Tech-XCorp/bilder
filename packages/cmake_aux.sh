#!/bin/bash
#
# Version and find information for cmake
#
# $Id$
#
######################################################################

getCmakeVersion() {
  CMAKE_BLDRVERSION_STD=${CMAKE_BLDRVERSION_STD:-"2.8.12.1"}
  CMAKE_BLDRVERSION_EXP=${CMAKE_BLDRVERSION_EXP:-"2.8.12.1"}
}
getCmakeVersion

######################################################################
#
# Find CMake
#
######################################################################

findCmake() {
  CMAKE=`which cmake`
}


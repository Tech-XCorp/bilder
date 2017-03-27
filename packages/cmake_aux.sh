#!/bin/sh
######################################################################
#
# @file    cmake_aux.sh
#
# @brief   Trigger vars and find information.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
  CMAKE_BLDRVERSION_STD=${CMAKE_BLDRVERSION_STD:-"3.7.1"}
  CMAKE_BLDRVERSION_EXP=${CMAKE_BLDRVERSION_EXP:-"3.7.1"}
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
  if test -z "$CMAKE"; then
    echo "No cmake.  PATH = $PATH."
    exit
  fi
}


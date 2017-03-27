#!/bin/sh
######################################################################
#
# @file    clapack_cmake_aux.sh
#
# @brief   Trigger vars and find information for clapack_cmake.
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

setCLapack_CmakeTriggerVars() {
  CLAPACK_CMAKE_BLDRVERSION=${CLAPACK_CMAKE_BLDRVERSION:-"3.2.1"}
  CLAPACK_CMAKE_BUILDS=${CLAPACK_CMAKE_BUILDS:-"NONE"}
  if test $CLAPACK_CMAKE_BUILDS != NONE; then
    addPycshBuild clapack_lapack
  fi
  CLAPACK_CMAKE_DEPS=cmake
}
setCLapack_CmakeTriggerVars

######################################################################
#
# Find clapack_cmake
#
######################################################################

findCLapack_Cmake() {
  CLAPACK_CMAKE_INSTALLED=${CLAPACK_CMAKE_INSTALLED:-"false"}
  if $CLAPACK_CMAKE_INSTALLED; then
    findBlasLapack
  fi
}


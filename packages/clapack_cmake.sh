#!/bin/sh
######################################################################
#
# @file    clapack_cmake.sh
#
# @brief   Build information for clapack_cmake.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in clapack_cmake_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/clapack_cmake_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCLapack_CmakeNonTriggerVars() {
  CLAPACK_CMAKE_UMASK=002
}
setCLapack_CmakeNonTriggerVars

######################################################################
#
# Launch clapack_cmake builds.
#
######################################################################

buildCLapack_CMake() {

  if ! bilderUnpack clapack_cmake; then
    return
  fi

  local CLAPACK_BUILD_ARGS=
  if [[ `uname` =~ CYGWIN ]]; then
    CLAPACK_BUILD_ARGS="-m nmake"
  fi

  if bilderConfig clapack_cmake ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CLAPACK_CMAKE_SER_OTHER_ARGS $TARBALL_NODEFLIB_FLAGS"; then
    bilderBuild $CLAPACK_BUILD_ARGS clapack_cmake ser
  fi

# sermd keeps the /MD flags when compiling and building the CLAPACK library.
  if bilderConfig clapack_cmake sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CLAPACK_CMAKE_SER_OTHER_ARGS"; then
    bilderBuild $CLAPACK_BUILD_ARGS clapack_cmake sermd
  fi

}

######################################################################
#
# Test clapack_cmake
#
######################################################################

testCLapack_CMake() {
  techo "Not testing clapack_cmake."
}

######################################################################
#
# Install clapack_cmake
#
######################################################################

# Create lapackf2c: lapack for fortran symbols
#
# Args
# 1: the build
#
makeLapackf2c() {

  case `uname` in
    CYGWIN* | MINGW*)
      cd $CONTRIB_DIR/clapack_cmake-${CLAPACK_CMAKE_BLDRVERSION}-ser/lib
      mv libf2c.lib f2c.lib
      cd $CONTRIB_DIR/clapack_cmake-${CLAPACK_CMAKE_BLDRVERSION}-sermd/lib
      mv libf2c.lib f2c.lib
      ;;
  esac

}

installCLapack_CMake() {
  CLAPACK_CMAKE_INSTALLED=false
  for bld in ser sermd pycsh; do
    if bilderInstall clapack_cmake $bld; then
      makeLapackf2c $bld
      CLAPACK_CMAKE_INSTALLED=true
    fi
  done
}


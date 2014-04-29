#!/bin/bash
#
# Version and build information for clapack_cmake
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

CLAPACK_CMAKE_BLDRVERSION=${CLAPACK_CMAKE_BLDRVERSION:-"3.2.1"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setCLapackCmakeGlobalVars () {
# Machine files should enable these builds as needed.
# E.g., for Windows, modify cygwin.vs.
  CLAPACK_CMAKE_BUILDS=${CLAPACK_CMAKE_BUILDS:-"NONE"}
  CLAPACK_CMAKE_DEPS=cmake
  if test $CLAPACK_CMAKE_BUILDS != NONE; then
    addCc4pyBuild clapack_lapack
  fi
}
setCLapackCmakeGlobalVars

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
  local anyinstalled=false
  for bld in ser sermd cc4py; do
    if bilderInstall clapack_cmake $bld; then
      makeLapackf2c $bld
      anyinstalled=true
    fi
  done
  if $anyinstalled; then
    findBlasLapack
  fi
}


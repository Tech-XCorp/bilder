#!/bin/bash
#
# Version and build information for clapack_cmake
#
# $Id: clapack_cmake.sh 4804 2012-01-07 10:43:55Z cary $
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
# Other values
#
######################################################################

# Change clapack_cmake builds only if not set.
# Needed for windows.
if test -z "$CLAPACK_CMAKE_BUILDS"; then
  case `uname`-$CC in
    CYGWIN*-mingw*)
      CLAPACK_CMAKE_BUILDS=NONE
      ;;
    CYGWIN*) # Darwin has -framework Accelerate
      CLAPACK_CMAKE_BUILDS=ser
      addCc4pyBuild clapack_cmake
      ;;
    *)
      CLAPACK_CMAKE_BUILDS=NONE
      ;;
  esac
fi
CLAPACK_CMAKE_DEPS=cmake

######################################################################
#
# Launch clapack_cmake builds.
#
######################################################################

buildCLapack_CMake() {

  if bilderUnpack clapack_cmake; then

    if bilderConfig clapack_cmake ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CLAPACK_CMAKE_SER_OTHER_ARGS $CMAKE_NODEFLIB_FLAGS"; then
      bilderBuild clapack_cmake ser
    fi

# JRC: Why was this commented out?
    if false; then
# Add the pycc flags
    if bilderConfig clapack_cmake cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CLAPACK_CMAKE_PYC_OTHER_ARGS"; then
      bilderBuild clapack_cmake cc4py
    fi
    fi

  fi
  return 0

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
  cd $CONTRIB_DIR/clapack_cmake-${CLAPACK_CMAKE_BLDRVERSION}-ser/lib
  case `uname` in
    CYGWIN* | MINGW*)
      mv libf2c.lib f2c.lib
      ;;
  esac
}

installCLapack_CMake() {
  local anyinstalled=false
  for bld in ser cc4py; do
    if bilderInstall clapack_cmake $bld; then
      makeLapackf2c $bld
      anyinstalled=true
    fi
  done
  if $anyinstalled; then
    findBlasLapack
  fi
  return 0
}


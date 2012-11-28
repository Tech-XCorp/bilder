#!/bin/bash
#
# Version and build information for gpulib
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Builds and deps
#
######################################################################

# Don't reset GPULIB_BUILDS if set.
if test -z "$GPULIB_BUILDS"; then
  GPULIB_BUILDS=${GPULIB_BUILDS:-"gpu"}
fi

# Dependencies
if test -z "$GPULIB_DEPS"; then
  MAGMA_CONFIG=" "
  GPULIB_DEPS=cmake
  case `uname` in
    Linux*)
      MAGMA_CONFIG="-DMAGMA_ROOT=$CONTRIB_DIR/magma -DAtlas_ROOT_DIR=$CONTRIB_DIR/atlas"
      GPULIB_DEPS=$GPULIB_DEPS,magma
      ;;
  esac
fi

######################################################################
#
# Launch gpulib builds.
#
######################################################################

buildGPULib() {

# Fix ranlib on aix
  case `uname` in
    AIX)
      GPULIB_MAKE_ARGS=${GPULIB_MAKE_ARGS:-"RANLIB=:"}
      GPULIB_MAKE_ARGS="$GPULIB_MAKE_ARGS $GPULIB_MAKEJ_ARGS"
      ;;
    CYGWIN*)
      if which jom 1>/dev/null 2>/dev/null; then
        GPULIB_MAKE_ARGS="$GPULIB_MAKEJ_ARGS"
      fi
      ;;
    Darwin | Linux)
      GPULIB_MAKE_ARGS="$GPULIB_MAKE_ARGS $GPULIB_MAKEJ_ARGS"
      export LD_LIBRARY_PATH=/usr/local/cuda-4.2/cuda/lib64:/usr/local/cuda/4.2/cuda/lib64:$LD_LIBRARY_PATH
      ;;
  esac
  GPULIB_PAR_MAKE_ARGS="$GPULIB_MAKE_ARGS"
  GPULIB_SER_MAKE_ARGS="$GPULIB_MAKE_ARGS"

# Configure and build serial and parallel
  getVersion gpulib
  if bilderPreconfig gpulib; then
    if bilderConfig $forcecmake gpulib gpu "$MAGMA_CONFIG $GEN_SUPRA_SP_ARG"; then
      if test -z "$forcecmake"; then
        GPULIB_SINGLE_MAKE_ARGS=""
      fi
      bilderBuild gpulib gpu "gpulib"
    fi
  fi

}

######################################################################
#
# Test GPULib
#
######################################################################

testGPULib() {
  # wait for build before testing it
  waitBuild gpulib-$GPULIB_BUILDS

  # find make commmand
  local cmvar=GPULIB_CONFIG_METHOD
  local cmval=`deref $cmvar`
  bildermake="`getMaker $cmval`"

  # construct test execution command
  cmd="$bildermake test"
  $cmd
}

######################################################################
#
# Install gpulib
#
######################################################################

installGPULib() {
  bilderInstall gpulib gpu
}


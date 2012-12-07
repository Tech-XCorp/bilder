#!/bin/bash
#
# Version and build information for cosml
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

# cosml.sh is invoked twice and the first time through, in the initial
# setup, PETSC33_BUILDS will always be blank.  Because we want to follow
# PETSC33_BUILDS, we do not do the normal method and have to reset the
# builds down below in each method.  So this is just a dummy
COSML_BUILDS="cc4py"

# Removing Python,numpy,tables as not really a build dep.
COSML_DEPS=chrpath,openmpi,cmake,lapack,petsc33,cosml_lite,Sphinx
#if $BUILD_OPTIONAL; then
#   COSML_DEPS=${COSML_DEPS},cython,matplotlib,scipy,tables,pynetcdf4,ipython
#fi
COSML_UMASK=007
#if test -d $PROJECT_DIR/petscdev; then
#   COSML_DEPS=${COSML_DEPS},petscdev
#else
#   COSML_DEPS=${COSML_DEPS},petsc
#fi

######################################################################
#
# Launch cosml builds.
#
######################################################################

# Configure and build serial and parallel
buildcosml() {
  COSML_BUILDS=$PETSC33_BUILDS
# Get version and see if anything needs building
  getVersion cosml
  if bilderPreconfig cosml; then
    for build in `echo $COSML_BUILDS | tr , " "`; do
      if bilderConfig -c cosml $build "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $COSML_CC4PY_FLAGS $COSML_CC4PY_ADDL_ARGS -DUSE_PETSC_INSTALL=$build" "" "$COSML_ENV_ARGS"; then
        bilderBuild cosml $build
      fi
    done
  fi
}

######################################################################
#
# Test cosml
#
######################################################################

# Set umask to allow only group to modify
testcosml() {
  echo "Not testing"
}

######################################################################
#
# Install cosml
#
######################################################################

installcosml() {
    COSML_BUILDS=$PETSC33_BUILDS
    for build in `echo $COSML_BUILDS | tr , " "`; do
      bilderInstall cosml $build
    done
}


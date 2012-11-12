#!/bin/bash
#
# Version and build information for cosml
#
# $Id: cosml.sh 6949 2012-11-06 13:38:46Z austin $
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

if test -z "$COSML_BUILDS"; then
  COSML_BUILDS="cc4py"
fi
# Removing Python,numpy,tables as not really a build dep.
COSML_DEPS=chrpath,openmpi,cmake,lapack,petsc33,cython,cosml_lite
if $BUILD_OPTIONAL; then
   COSML_DEPS=${COSML_DEPS},Sphinx,matplotlib,scipy,tables,pynetcdf4,ipython
fi
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
# Get version and see if anything needs building
  getVersion cosml
  if bilderPreconfig cosml; then
    if bilderConfig -c cosml cc4py "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $COSML_CC4PY_FLAGS $COSML_CC4PY_ADDL_ARGS" "" "$COSML_ENV_ARGS"; then
      bilderBuild cosml cc4py
    fi
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
    bilderInstall cosml cc4py

}


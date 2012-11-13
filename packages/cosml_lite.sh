#!/bin/bash
#
# Version and build information for cosml_lite
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

if test -z "$COSML_LITE_BUILDS"; then
  COSML_LITE_BUILDS="cc4py"
fi
# Removing Python,numpy,tables as not really a build dep.
COSML_LITE_DEPS=chrpath,cmake,lapack
if $BUILD_OPTIONAL; then
   COSML_LITE_DEPS=${COSML_LITE_DEPS}
fi
COSML_LITE_UMASK=007

######################################################################
#
# Launch cosml_lite builds.
#
######################################################################

# Configure and build serial and parallel
buildcosml_lite() {
# Get version and see if anything needs building
  getVersion cosml_lite
  if bilderPreconfig cosml_lite; then
    if bilderConfig -c cosml_lite cc4py "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $COSML_LITE_CC4PY_FLAGS $COSML_LITE_CC4PY_ADDL_ARGS" "" "$COSML_LITE_ENV_ARGS"; then
      bilderBuild cosml_lite cc4py
    fi
  fi


}

######################################################################
#
# Test cosml_lite
#
######################################################################

# Set umask to allow only group to modify
testcosml_lite() {
  echo "Not testing"
}

######################################################################
#
# Install cosml_lite
#
######################################################################

installcosml_lite() {
    bilderInstall cosml_lite cc4py
}


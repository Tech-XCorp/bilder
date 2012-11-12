#!/bin/bash
#
# For building psexamples
#
# $Id: psexamples.sh 6775 2012-09-30 15:45:20Z cary $
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

PSEXAMPLES_BUILDS=lite
PSEXAMPLES_DEPS=sphinx_numfig,Sphinx,MathJax,cmake
PSEXAMPLES_UMASK=002

######################################################################
#
# Launch psexamples builds.
# The odd thing is that ultimately we want to builds:
#    autotools builds for txtest functionality
#    cmake builds for installation
#
######################################################################

# Configure and build serial and parallel
buildPsexamples() {
# Get version and see if anything needs building
  getVersion psexamples
  if bilderPreconfig psexamples; then

# Figure out polyswift version
    local PSEXAMPLES_ADDL_ARGS=
    if test -d $PROJECT_DIR/polyswift; then
      getVersion polyswift
      for val in MAJOR MINOR PATCH; do
        eval POLYSWIFT_VERSION_$val=`grep "set(VERSION_$val" $PROJECT_DIR/polyswift/CMakeLists.txt | sed -e 's/").*$//' -e 's/^.*"//'`
      done
      POLYSWIFT_PROJVERSION=${POLYSWIFT_VERSION_MAJOR}.${POLYSWIFT_VERSION_MINOR}.${POLYSWIFT_VERSION_MINOR}
      PSEXAMPLES_ADDL_ARGS="-DPOLYSWIFT_PROJVERSION:STRING=${POLYSWIFT_PROJVERSION} -DPOLYSWIFT_BLDRVERSION=${POLYSWIFT_BLDRVERSION}"
    fi

    if bilderConfig psexamples lite "$PSEXAMPLES_ADDL_ARGS $CMAKE_SUPRA_SP_ARG -DPSEX_STANDALONE=TRUE"; then
      bilderBuild psexamples lite
    fi

  fi
}

######################################################################
#
# Test polyswift
#
######################################################################

# Set umask to allow only group to modify
testPsexamples() {
  :
}

######################################################################
#
# Install polyswift
#
######################################################################

installPsexamples() {
  bilderInstall psexamples lite
  # techo "WARNING: Quitting at end of installPsexamples."; cleanup
}


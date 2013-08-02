#!/bin/bash
#
# Version and build information for Votca
#
# $Id: votca_tools.sh 290 2013-07-18 18:06:28Z swsides $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# This is the revision number from the Mercurial repo
VOTCA_TOOLS_BLDRVERSION=${VOTCA_TOOLS_BLDRVERSION:-"r583"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VOTCA_TOOLS_BUILDS=${VOTCA_TOOLS_BUILDS:-"ser"}
VOTCA_TOOLS_DEPS=fftw3,boost,gsl

# addtopathvar PATH $CONTRIB_DIR/votca_tools/bin

######################################################################
#
# Common arguments to find stuff or to simplify the builds
# See notes at the end
#
######################################################################

# 
VOTCA_TOOLS_ADDL_ARGS="-DBOOST_INCLUDEDIR:PATH=$CONTRIB_DIR/boost/include"

#case `uname` in
#    CYGWIN* | Darwin) VOTCA_TOOLS_PAR_OTHER_ARGS="-DMPI_INCLUDE_PATH:FILEPATH=$CONTRIB_DIR/openmpi/include -DMPI_LIBRARY:FILEPATH=$CONTRIB_DIR/openmpi/lib/libmpi_cxx.dylib";;
#    Linux)            VOTCA_TOOLS_PAR_OTHER_ARGS="-DMPI_INCLUDE_PATH:FILEPATH=$CONTRIB_DIR/openmpi/include -DMPI_LIBRARY:FILEPATH=$CONTRIB_DIR/openmpi/lib/libmpicxx.a";;
#esac

######################################################################
#
# Launch votca_tools builds.
#
######################################################################
buildVotca_Tools() {

  # Setting non-optional dependencies
  VOTCA_TOOLS_ARGS="$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DBOOST_INCLUDEDIR:PATH=$CONTRIB_DIR/boost/include"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DWITH_FFTW=ON  -DWITH_GSL=ON"

  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DFFTW3_INCLUDE_DIR:PATH='$CONTRIB_DIR/fftw3/include'"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DFFTW3_LIBRARY:FILEPATH='$CONTRIB_DIR/fftw3/lib/libfftw3.a'"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DGSL_INCLUDE_DIR:PATH='$CONTRIB_DIR/gsl/include'"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DGSL_LIBRARY:FILEPATH='$CONTRIB_DIR/gsl/lib/libgsl.a'"


  if bilderUnpack votca_tools; then

    # Serial build
    if bilderConfig -c votca_tools ser "$VOTCA_TOOLS_ARGS"; then
      bilderBuild votca_tools ser "$VOTCA_TOOLS_MAKEJ_ARGS"
    fi

  fi
}

######################################################################
#
# Test votca_tools
#
######################################################################

testVotca_Tools() {
  techo "Not testing votca_tools."
}

######################################################################
#
# Install votca_tools
#
######################################################################

installVotca_Tools() {
  bilderInstall votca_tools ser votca_tools-ser
}



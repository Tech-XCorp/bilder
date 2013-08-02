#!/bin/bash
#
# Version and build information for Votca
#
# $Id: votca_csg.sh 290 2013-07-18 18:06:28Z swsides $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# This is the revision number from the Mercurial repo
VOTCA_CSG_BLDRVERSION=${VOTCA_CSG_BLDRVERSION:-"r583"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VOTCA_CSG_BUILDS=${VOTCA_CSG_BUILDS:-"ser"}
VOTCA_CSG_DEPS=fftw3,boost,gsl

# addtopathvar PATH $CONTRIB_DIR/votca_csg/bin

######################################################################
#
# Common arguments to find stuff or to simplify the builds
# See notes at the end
#
######################################################################

# 
VOTCA_CSG_ADDL_ARGS="-DBOOST_INCLUDEDIR:PATH=$CONTRIB_DIR/boost/include"

#case `uname` in
#    CYGWIN* | Darwin) VOTCA_CSG_PAR_OTHER_ARGS="-DMPI_INCLUDE_PATH:FILEPATH=$CONTRIB_DIR/openmpi/include -DMPI_LIBRARY:FILEPATH=$CONTRIB_DIR/openmpi/lib/libmpi_cxx.dylib";;
#    Linux)            VOTCA_CSG_PAR_OTHER_ARGS="-DMPI_INCLUDE_PATH:FILEPATH=$CONTRIB_DIR/openmpi/include -DMPI_LIBRARY:FILEPATH=$CONTRIB_DIR/openmpi/lib/libmpicxx.a";;
#esac

######################################################################
#
# Launch votca_csg builds.
#
######################################################################
buildVotca_Csg() {

  # Setting non-optional dependencies
  VOTCA_CSG_ARGS="$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG"
  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DBOOST_INCLUDEDIR:PATH=$CONTRIB_DIR/boost/include"
  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DWITH_FFTW=ON  -DWITH_GSL=ON"

  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DFFTW3_INCLUDE_DIR:PATH='$CONTRIB_DIR/fftw3/include'"
  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DFFTW3_LIBRARY:FILEPATH='$CONTRIB_DIR/fftw3/lib/libfftw3.a'"
  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DGSL_INCLUDE_DIR:PATH='$CONTRIB_DIR/gsl/include'"
  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DGSL_LIBRARY:FILEPATH='$CONTRIB_DIR/gsl/lib/libgsl.a'"

  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DEXPAT_INCLUDE_DIR:PATH='$CONTRIB_DIR/expat/include'"
  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DEXPAT_LIBRARY:FILEPATH='$CONTRIB_DIR/expat/lib/libexpat.dylib'"

  if bilderUnpack votca_csg; then

    # Serial build
    if bilderConfig -c votca_csg ser "$VOTCA_CSG_ARGS"; then
      bilderBuild votca_csg ser "$VOTCA_CSG_MAKEJ_ARGS"
    fi

  fi
}

######################################################################
#
# Test votca_csg
#
######################################################################

testVotca_Csg() {
  techo "Not testing votca_csg."
}

######################################################################
#
# Install votca_csg
#
######################################################################

installVotca_Csg() {
  bilderInstall votca_csg ser votca_csg-ser
}

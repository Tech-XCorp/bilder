#!/bin/sh
######################################################################
#
# @file    votca_tools.sh
#
# @brief   Version and build information for Votca_tools.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# This is the revision number from the Mercurial repo
# VOTCA_TOOLS_BLDRVERSION=${VOTCA_TOOLS_BLDRVERSION:-"r583"}
VOTCA_TOOLS_BLDRVERSION=${VOTCA_TOOLS_BLDRVERSION:-"r590"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VOTCA_TOOLS_BUILDS=${VOTCA_TOOLS_BUILDS:-"ser"}
VOTCA_TOOLS_DEPS=fftw3,boost,gsl,expat,sqlite,cmake

case `uname` in
    CYGWIN* | Darwin)
        addtopathvar DYLD_LIBRARY_PATH $CONTRIB_DIR/votca_tools-ser/lib
        ;;
    Linux)
        addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/votca_tools-ser/lib
        ;;
esac

######################################################################
#
# Launch votca_tools builds.
#
######################################################################
buildVotca_Tools() {

  # Setting non-optional dependencies
  VOTCA_TOOLS_ARGS="$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DWITH_FFTW=ON -DWITH_GSL=ON"

  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DFFTW3_INCLUDE_DIR:PATH='$CONTRIB_DIR/fftw3/include'"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DFFTW3_LIBRARY:FILEPATH='$CONTRIB_DIR/fftw3/lib/libfftw3.a'"

  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DGSL_INCLUDE_DIR:PATH='$CONTRIB_DIR/gsl/include'"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DGSL_LIBRARY:FILEPATH='$CONTRIB_DIR/gsl/lib/libgsl.a'"

  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DEXPAT_INCLUDE_DIR:PATH='$CONTRIB_DIR/expat/include'"
  VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DSQLITE3_INCLUDE_DIR:PATH='$CONTRIB_DIR/sqlite-sersh/include'"
  case `uname` in
      CYGWIN* | Darwin)
          VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DEXPAT_LIBRARY:FILEPATH='$CONTRIB_DIR/expat/lib/libexpat.dylib'"
          VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DSQLITE3_LIBRARY:FILEPATH='$CONTRIB_DIR/sqlite-sersh/lib/libsqlite3.dylib'"
          ;;
      Linux)
          VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DEXPAT_LIBRARY:FILEPATH='$CONTRIB_DIR/expat/lib/libexpat.so'"
          VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DSQLITE3_LIBRARY:FILEPATH='$CONTRIB_DIR/sqlite-sersh/lib/libsqlite3.so'"
          ;;
  esac

  #
  # Votca cmake modules will corrupt lib finding if another boost is found
  # Fixing this on Peregrine through machine file
  # VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS BOOST_INCLUDEDIR=$CONTRIB_DIR/boost/include"
  # VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS BOOST_LIBRARYDIR=$CONTRIB_DIR/boost/lib"
  #
  if [[ -z $BOOST_INCLUDEDIR ]]; then
      techo -2 "BOOST_INCLUDEDIR enviroment var is unset. Will set BOOST_ROOT"
      VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS -DBOOST_ROOT:PATH=$CONTRIB_DIR/boost"
  else
      VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS BOOST_INCLUDEDIR=$CONTRIB_DIR/boost/include"
      VOTCA_TOOLS_ARGS="$VOTCA_TOOLS_ARGS BOOST_LIBRARYDIR=$CONTRIB_DIR/boost/lib"
      techo -2 "BOOST_INCLUDEDIR enviroment var is set. Assuming BOOST_LIBRARYDIR is set."
  fi

  if bilderUnpack votca_tools; then

    techo -2 "Will configure with VOTCA_TOOLS_ARGS = $VOTCA_TOOLS_ARGS"
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

#!/bin/sh
######################################################################
#
# @file    votca_csg.sh
#
# @brief   Version and build information for Votca.
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
# VOTCA_CSG_BLDRVERSION=${VOTCA_CSG_BLDRVERSION:-"r2134"}
VOTCA_CSG_BLDRVERSION=${VOTCA_CSG_BLDRVERSION:-"r2135"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

VOTCA_CSG_BUILDS=${VOTCA_CSG_BUILDS:-"ser"}
VOTCA_CSG_DEPS=boost,votca_tools,cmake

######################################################################
#
# Launch votca_csg builds.
#
######################################################################
buildVotca_Csg() {

  # Setting non-optional dependencies
  VOTCA_CSG_ARGS="$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG"

  # Turning off gromacs support (because no gromacs part of bilder)
  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DWITH_GMX=OFF"

  VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DVOTCA_TOOLS_INCLUDE_DIR:PATH='$CONTRIB_DIR/votca_tools-ser/include'"
  case `uname` in
      CYGWIN* | Darwin)
          # lib path needed because a built executable is called as part of build
          export DYLD_LIBRARY_PATH=$CONTRIB_DIR/votca_tools-ser/lib:$DYLD_LIBRARY_PATH
          VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DVOTCA_TOOLS_LIBRARY:FILEPATH='$CONTRIB_DIR/votca_tools-ser/lib/libvotca_tools.dylib'" ;;
      Linux)
          export LD_LIBRARY_PATH=$CONTRIB_DIR/votca_tools-ser/lib:$LD_LIBRARY_PATH
          VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DVOTCA_TOOLS_LIBRARY:FILEPATH='$CONTRIB_DIR/votca_tools-ser/lib/libvotca_tools.so'" ;;
  esac

  #
  # Votca cmake modules will corrupt lib finding if another boost is found
  # Fixing this on Peregrine through machine file
  #
  if [[ -z $BOOST_INCLUDEDIR ]]; then
      techo -2 "BOOST_INCLUDEDIR enviroment var is unset. Will set BOOST_ROOT"
      VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS -DBOOST_ROOT:PATH=$CONTRIB_DIR/boost"
  else
      VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS BOOST_INCLUDEDIR=$CONTRIB_DIR/boost/include"
      VOTCA_CSG_ARGS="$VOTCA_CSG_ARGS BOOST_LIBRARYDIR=$CONTRIB_DIR/boost/lib"
      techo -2 "BOOST_INCLUDEDIR enviroment var is set. Assuming BOOST_LIBRARYDIR is set."
  fi

  #
  # Main build command
  #
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

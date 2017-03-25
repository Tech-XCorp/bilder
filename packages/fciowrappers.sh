#!/bin/sh
######################################################################
#
# @file    fciowrappers.sh
#
# @brief   Documentation goes here.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

#!/bin/bash
#
# Version and build information for fciowrappers
#
# $Rev$ $Date$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

FCIOWRAPPERS_BLDRVERSION=${FCIOWRAPPERS_BLDRVERSION:-"1.1.1-r175"}

######################################################################
#
# Other values
#
######################################################################

FCIOWRAPPERS_BUILDS=${FCIOWRAPPERS_BUILDS:-"ser,par"}
FCIOWRAPPERS_DEPS=hdf5,$MPI_BUILD
# Right now netcdf has separated the C and fortran libraries
# which is a total pain so just skip it.
FCIOWRAPPERS_DEPS=hdf5,netcdf,netcdf_fortran,$MPI_BUILD

######################################################################
#
# Launch fciowrappers builds.
#
######################################################################

buildFciowrappersCM() {

  if ! $FC_HDF5; then
    techo "$FC cannot build hdf5, so cannot build fciowrappers."
    return
  fi

# Allow fciowrappers to be either from svnrepo or tarball.
  if test -d $PROJECT_DIR/fciowrappers; then
    getVersion fciowrappers
    bilderPreconfig -c fciowrappers
    res=$?
  else
    bilderUnpack fciowrappers
    res=$?
  fi

# Build both builds
  if test $res = 0; then
    if bilderConfig -c fciowrappers ser "$CMAKE_COMPILERS_SER $FCIOWRAPPERS_FORTRAN_ARGS $CMAKE_COMPFLAGS_SER $FCIOWRAPPERS_SER_OTHER_ARGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild fciowrappers ser
    fi
    if bilderConfig -c fciowrappers par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $FCIOWRAPPERS_FORTRAN_ARGS $CMAKE_COMPFLAGS_SER $FCIOWRAPPERS_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild fciowrappers par $LD_RUN_VAR
    fi
  fi

}

buildFciowrappers() {
  if test -d $PROJECT_DIR/fciowrappers; then
    techo "WARNING: Building the repo, $PROJECT_DIR/fciowrappers."
  fi
  if test $CONTRIB_DIR != $BLDR_INSTALL_DIR; then
    local insts=`\ls -d $BLDR_INSTALL_DIR/fciowrappers*`
    if test -n "$insts"; then
      techo "WARNING: fciowrappers is installed in $BLDR_INSTALL_DIR."
    fi
  fi
  buildFciowrappersCM
}

######################################################################
#
# Test fciowrappers
#
######################################################################

testFciowrappers() {
  #techo "Not testing fciowrappers."
  startdir=$PWD
# This is currently an error.  Need to use waitAction to see if there
# was a build.  Iffing out for now.
  if false; then
  for dir in $BUILD_DIR/fciowrappers-*; do
    cd $dir
    make test
  done
  fi
  cd $startdir
}

######################################################################
#
# Install fciowrappers
#
######################################################################

installFciowrappers() {
  bilderInstall fciowrappers ser
  bilderInstall fciowrappers par
  # techo "Quitting at end of fciowrappers.sh."; cleanup
}


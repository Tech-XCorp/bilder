#!/bin/sh
######################################################################
#
# @file    fftw3.sh
#
# @brief   Version and build information for fftw3.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

FFTW3_BLDRVERSION=${FFTW3_BLDRVERSION:-"3.3.4"}

######################################################################
#
# Other values
#
######################################################################

# FFTW3 has both serial and parallel builds
# TORIC requires only the serial build
# PolySwift requires the parallel build
FFTW3_BUILDS=${FFTW3_BUILDS:-"ser,par"}
addBenBuild fftw3
FFTW3_DEPS=$MPI_BUILD

######################################################################
#
# Launch FFTW3 builds.
#
######################################################################

buildFftw3() {

# SWS: if F77 is specified for MPI built without fortran,
# the configure will fail
  FFTW3_CONFIG_COMPILERS_PAR="--enable-mpi CC='$MPICC' MPICC='$MPICC' CXX='$MPICXX'"
  if test -n "$MPIFC" || which $MPIFC 2>/dev/null; then
    FFTW3_CONFIG_COMPILERS_PAR="$FFTW3_CONFIG_COMPILERS_PAR FC='$MPIFC' F77='$MPIF77'"
  else
    FFTW3_CONFIG_COMPILERS_PAR="--disable-fortran $FFTW3_CONFIG_COMPILERS_PAR"
  fi

  if bilderUnpack fftw3; then
# They have a config.h that causes problems
    rm -f $BUILD_DIR/fftw3-$FFTW3_BLDRVERSION/fftw/config.h
    if bilderConfig fftw3 ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS $FFTW3_SER_OTHER_ARGS"; then
      bilderBuild fftw3 ser
    fi
    if bilderConfig fftw3 ben "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR $PAR_CONFIG_LDFLAGS $FFTW3_BEN_OTHER_ARGS"; then
      bilderBuild fftw3 ben
    fi
    if bilderConfig fftw3 par "--disable-type-prefix $FFTW3_CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $PAR_CONFIG_LDFLAGS $FFTW3_PAR_OTHER_ARGS"; then
      bilderBuild fftw3 par
    fi
  fi

}

######################################################################
#
# Test Fftw
#
######################################################################

testFftw3() {
  techo "Not testing fftw."
}

######################################################################
#
# Install fftw
#
######################################################################

installFftw3() {
  bilderInstall fftw3 ser fftw3
  bilderInstall fftw3 par fftw3-par
  bilderInstall fftw3 ben fftw3-ben
}

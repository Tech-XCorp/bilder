#!/bin/bash
#
# Version and build information for fftw
#
# $Id: fftw.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

FFTW_BLDRVERSION=${FFTW_BLDRVERSION:-"2.1.5"}

######################################################################
#
# Other values
#
######################################################################

# FFTW has both serial and parallel builds
# TORIC requires only the serial build
# PolySwift requires the parallel build
FFTW_BUILDS=${FFTW_BUILDS:-"ser,par"}
addBenBuild fftw
FFTW_DEPS=openmpi

######################################################################
#
# Launch FFTW builds.
#
######################################################################

buildFftw() {

# SWS: if F77 is specified for MPI built without fortran,
# the configure will fail
  FFTW_CONFIG_COMPILERS_PAR="--enable-mpi CC='$MPICC' MPICC='$MPICC' CXX='$MPICXX'"
  if test -n "$MPIFC" || which $MPIFC 2>/dev/null; then
    FFTW_CONFIG_COMPILERS_PAR="$FFTW_CONFIG_COMPILERS_PAR FC='$MPIFC'"
  else
    FFTW_CONFIG_COMPILERS_PAR="--disable-fortran $FFTW_CONFIG_COMPILERS_PAR"
  fi

  if bilderUnpack fftw; then
# They have a config.h that causes problems
    rm -f $BUILD_DIR/fftw-$FFTW_BLDRVERSION/fftw/config.h
    # if bilderConfig fftw ser "--enable-fortran $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS $FFTW_SER_OTHER_ARGS"; then
    # --enable-fortran is the default
    if bilderConfig fftw ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS $FFTW_SER_OTHER_ARGS"; then
      bilderBuild fftw ser
    fi
    if bilderConfig fftw ben "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR $PAR_CONFIG_LDFLAGS $FFTW_BEN_OTHER_ARGS"; then
      bilderBuild fftw ben
    fi
    if bilderConfig fftw par "--disable-type-prefix $FFTW_CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $PAR_CONFIG_LDFLAGS $FFTW_PAR_OTHER_ARGS"; then
      bilderBuild fftw par
    fi
  fi

}



######################################################################
#
# Test Fftw
#
######################################################################

testFftw() {
  techo "Not testing fftw."
}

######################################################################
#
# Install fftw
#
######################################################################

installFftw() {
# makeinfo causes problems at benten.gat.com
  bilderInstall fftw ser fftw MAKEINFO=:
  bilderInstall fftw par fftw-par MAKEINFO=:
  bilderInstall fftw ben fftw-ben MAKEINFO=:
}

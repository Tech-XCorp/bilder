#!/bin/bash
#
# Version and build information for sundials
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SUNDIALS_BLDRVERSION=${SUNDIALS_BLDRVERSION:-"2.4.0"}

######################################################################
#
# Other values
#
######################################################################

# SUNDIALS has both serial and parallel builds
SUNDIALS_BUILDS=${SUNDIALS_BUILDS:-"ser,par"}
addBenBuild sundials
SUNDIALS_DEPS=$MPI_BUILD

######################################################################
#
# Launch SUNDIALS builds.
#
######################################################################

buildSundials() {

# SWS: if F77 is specified for MPI built without fortran,
# the configure will fail
  SUNDIALS_CONFIG_COMPILERS_PAR="--enable-mpi CC='$MPICC' MPICC='$MPICC' CXX='$MPICXX'"
  if test -n "$MPIFC" || which $MPIFC 2>/dev/null; then
    SUNDIALS_CONFIG_COMPILERS_PAR="$SUNDIALS_CONFIG_COMPILERS_PAR FC='$MPIFC'"
  else
    SUNDIALS_CONFIG_COMPILERS_PAR="--disable-fortran $SUNDIALS_CONFIG_COMPILERS_PAR"
  fi

  if bilderUnpack sundials; then
# They have a config.h that causes problems
    rm -f $BUILD_DIR/sundials-$SUNDIALS_BLDRVERSION/sundials/config.h
    # if bilderConfig sundials ser "--enable-fortran $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS $SUNDIALS_SER_OTHER_ARGS"; then
    # --enable-fortran is the default
    if bilderConfig sundials ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $SER_CONFIG_LDFLAGS $SUNDIALS_SER_OTHER_ARGS"; then
      bilderBuild sundials ser
    fi
    if bilderConfig sundials ben "$CONFIG_COMPILERS_BEN $CONFIG_COMPFLAGS_PAR $PAR_CONFIG_LDFLAGS $SUNDIALS_BEN_OTHER_ARGS"; then
      bilderBuild sundials ben
    fi
    if bilderConfig sundials par "--disable-type-prefix $SUNDIALS_CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $PAR_CONFIG_LDFLAGS $SUNDIALS_PAR_OTHER_ARGS"; then
      bilderBuild sundials par
    fi
  fi

}



######################################################################
#
# Test Sundials
#
######################################################################

testSundials() {
  techo "Not testing sundials."
}

######################################################################
#
# Install sundials
#
######################################################################

installSundials() {
  bilderInstall sundials ser sundials
  bilderInstall sundials par sundials-par
  bilderInstall sundials ben sundials-ben
}

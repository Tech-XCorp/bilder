#!/bin/sh
######################################################################
#
# @file    fftw.sh
#
# @brief   Build information for fftw.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables and versions set in fftw_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/fftw_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setFftwNonTriggerVars() {
  FFTW_UMASK=002
}
setFftwNonTriggerVars

######################################################################
#
# Version
#
######################################################################

#FFTW_BLDRVERSION=${FFTW_BLDRVERSION:-"2.1.5"}
#FFTW_BLDRVERSION=${FFTW_BLDRVERSION:-"2.1.5.1"}

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
FFTW_DEPS=$MPI_BUILD,cmake

######################################################################
#
# Launch FFTW builds.
#
######################################################################

buildFftw() {
    case `uname` in
        CYGWIN* | Darwin )
            # cmake-ed version of fftw (not working on linux)
            buildFftw_Cmake
            ;;
        Linux)
            # standard autotools build (cmake not working on linux)
            buildFftw_Autotools
            ;;
    esac
}

#
# All defaults are set for cmake build currently. If options in configure.in
# are needed, then these need to be added to the CMakeLists.txt files and passed
# here. BenBuilds not called here either
#
buildFftw_Cmake() {

  rm -f $BUILD_DIR/fftw-$FFTW_BLDRVERSION/fftw/config.h

  if bilderUnpack fftw; then
    if bilderConfig -c fftw ser "$TARBALL_NODEFLIB_FLAGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild fftw ser "$FFTW_MAKEJ_ARGS"
    fi
    if bilderConfig -c fftw par "-DENABLE_PARALLEL:BOOL=TRUE $TARBALL_NODEFLIB_FLAGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild fftw par "$FFTW_MAKEJ_ARGS"
    fi
  fi
}

buildFftw_Autotools() {

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

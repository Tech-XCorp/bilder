#!/bin/bash
#
# Version and build information for corrcalc
#
# $Id$
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

CORRCALC_BUILDS=${CORRCALC_BUILDS:-"ser,par"}
echo "CORRCALC_BUILDS=${CORRCALC_BUILDS}"

CORRCALC_DEPS=txbase,hdf5,fftw,Python

######################################################################
#
# Launch corrcalc builds.
#
######################################################################

buildCorrcalc() {

# Set cmake options
  local CORRCALC_PAR_OTHER_ARGS="$CORRCALC_PAR_CMAKE_OTHER_ARGS"
  local CORRCALC_SER_OTHER_ARGS="$CORRCALC_SER_CMAKE_OTHER_ARGS"


# If python not present in other args, add the gen arg
  if echo $CORRCALC_PAR_OTHER_ARGS | grep -iqv python; then
    CORRCALC_PAR_OTHER_ARGS="$CORRCALC_PAR_OTHER_ARGS $PYTHON_GEN_ARG"
  fi
  if echo $CORRCALC_SER_OTHER_ARGS | grep -iqv python; then
    CORRCALC_SER_OTHER_ARGS="$CORRCALC_SER_OTHER_ARGS $PYTHON_GEN_ARG"
  fi

  # Fix ranlib on aix
  case `uname` in
    AIX)
      CORRCALC_MAKE_ARGS=${CORRCALC_MAKE_ARGS:-"RANLIB=:"}
      ;;
    Darwin)
      ;;
    Linux)
      ;;
  esac


  # Configure and build serial and parallel
  getVersion corrcalc
  if bilderPreconfig corrcalc; then

      # Parallel build
      if bilderConfig $USE_CMAKE_ARG corrcalc par "$ENABLE_PARALLEL_GEN_ARG $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CORRCALC_PAR_OTHER_ARGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG" corrcalc; then
	  bilderBuild corrcalc par "$CORRCALC_MAKEJ_ARGS $CORRCALC_MAKE_ARGS CXX=$BUILD_DIR/corrcalc/par/txutils/cxx"
      fi

      # Serial build
      if bilderConfig $USE_CMAKE_ARG corrcalc ser "$DISABLE_PARALLEL_GEN_ARG $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CORRCALC_SER_OTHER_ARGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG" corrcalc; then
	  bilderBuild corrcalc ser "$CORRCALC_MAKEJ_ARGS $CORRCALC_MAKE_ARGS CXX=$BUILD_DIR/corrcalc/ser/txutils/cxx"
      fi
  fi

}

######################################################################
#
# Test corrcalc
#
######################################################################

# Set umask to allow only group to modify
testCorrcalc() {
  techo "Not testing corrcalc."
}

######################################################################
#
# Install corrcalc
#
######################################################################

installCorrcalc() {

# Set umask to allow only group to use on some machines
  um=`umask`
  case $FQMAILHOST in
    *.nersc.gov | *.alcf.anl.gov)
      umask 027
      ;;
    *)
      umask 002
      ;;
  esac

# Install parallel first, then serial last to override utilities
  bilderInstall corrcalc par corrcalc
  bilderInstall corrcalc ser corrcalc

# Revert umask
  umask $um
}

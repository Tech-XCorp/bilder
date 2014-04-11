#!/bin/bash
#
# Version and build information for teaspink
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from repo.

######################################################################
#
# Other values
#
######################################################################

if test -z "$TEASPINK_BUILDS"; then
  TEASPINK_BUILDS="ser,par"
fi

# Deps include autotools for configuring packages
TEASPINK_DEPS=hdf5,gsl,fftw,libxml2,pcre,gperf,xercesc,muparser,autotools,cmake

######################################################################
#
# Launch teaspink builds.
#
######################################################################

buildTeaspink() {

# Check for svn version or package
  if test -d $PROJECT_DIR/teaspink; then
    getVersion teaspink
    bilderPreconfig -c teaspink
    res=$?
  else
    bilderUnpack teaspink
    res=$?
  fi
  #DM 11/29/2012: Currently teaspink can't be built in parallel.
  TEASPINK_MAKEJ_ARGS=

# Check if building documentation
  case "$DOCS_BUILDS" in
    "teaspinkdocs")
      techo "Will build teaspink documentation."
      TEASPINK_SER_OTHER_ARGS="${TEASPINK_SER_OTHER_ARGS} -DBUILD_TEASPINK_DOCS:BOOL=TRUE"
      ;;
    "")
      techo "Not building teaspink documentation."
      TEASPINK_SER_OTHER_ARGS="${TEASPINK_SER_OTHER_ARGS} -DBUILD_TEASPINK_DOCS:BOOL=FALSE"
      ;;
    *)
      techo "Unrecognised argument for option '-D'."
      techo "For teaspink documentation use '-D teaspinkdocs'."
      ;;
  esac

# Regular build
  if test $res = 0; then
    if bilderConfig -c teaspink par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $REPO_NODEFLIB_FLAGS $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $TEASPINK_PAR_OTHER_ARGS"; then
      bilderBuild teaspink par "$TEASPINK_MAKEJ_ARGS"
    fi
    if bilderConfig -c teaspink ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $REPO_NODEFLIB_FLAGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TEASPINK_SER_OTHER_ARGS"; then
      bilderBuild teaspink ser "$TEASPINK_MAKEJ_ARGS"
    fi
  fi
}

######################################################################
#
# Test teaspink
#
######################################################################

testTeaspink() {
  bilderRunTests teaspink TsTests
}

######################################################################
#
# Install teaspink
#
######################################################################

installTeaspink() {
  bilderInstallTestedPkg -r -p open teaspink TsTests
}


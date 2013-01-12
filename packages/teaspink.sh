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
  TEASPINK_BUILDS=ser
fi

# Deps include autotools for configuring packages
TEASPINK_DEPS=gsl,fftw,libxml2,pcre,gperf,xercesc,muparser,autotools,cmake

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
  #TEASPINK_MAKE_ARGS="$TEASPINK_MAKEJ_ARGS"
  #DM 11/29/2012: Currently teaspink can't be built in parallel.
  TEASPINK_MAKE_ARGS=

# Regular build
  if test $res = 0; then
# Do quotes around compilers cause problems with cygwin.vs9?
    if bilderConfig -c teaspink ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $REPO_NODEFLIB_FLAGS $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TEASPINK_SER_OTHER_ARGS"; then
      bilderBuild teaspink ser "$TEASPINK_MAKE_ARGS"
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


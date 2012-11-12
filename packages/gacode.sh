#!/bin/bash
#
# Version and build information for gacode
#
# $Id: gacode.sh 6594 2012-09-01 15:12:46Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

GACODE_BLDRVERSION=${GACODE_BLDRVERSION:-"8.3.16"}
# gacode can build from either tarball or svn repo.  This is for tarball

######################################################################
#
# Builds and deps
#
######################################################################

GACODE_BUILDS=${GACODE_BUILDS:-"ser,par"}
GACODE_DEPS=fftw,openmpi,fciowrappers
GACODE_UMASK=002

######################################################################
#
# Launch gacode builds.
#
######################################################################

buildGacodeCM() {

# Check for svn version or package
  if test -d $PROJECT_DIR/gacode; then
    getVersion gacode
    bilderPreconfig gacode
    res=$?
  else
    bilderUnpack gacode
    res=$?
  fi

  if test $res = 0; then
    if bilderConfig gacode ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER -DBUILD_SHARED:BOOL=FALSE $CMAKE_SUPRA_SP_ARG $GACODE_SER_OTHER_ARGS"; then
      bilderBuild gacode ser
    fi
# We can get funny MPI crashes if gacode built shared for parallel?
    if bilderConfig gacode par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR -DBUILD_SHARED:BOOL=FALSE -DENABLE_PARALLEL:BOOL=TRUE $CMAKE_SUPRA_SP_ARG $GACODE_PAR_OTHER_ARGS"; then
      bilderBuild gacode par
    fi
  fi

}


buildGacodeAT() {

# Check for svn version or package
  if test -d $PROJECT_DIR/gacode; then
    getVersion gacode
    bilderPreconfig -p shared/autotool_config/cleanconf.sh gacode
    res=$?
  else
    bilderUnpack gacode
    res=$?
  fi

  if test $res = 0; then
    if bilderConfig gacode ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $GACODE_SER_OTHER_ARGS --disable-shared --enable-static --disable-parallel $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild gacode ser
    fi
# We can get funny MPI crashes if gacode built shared for parallel?
    if bilderConfig gacode par "$CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR --enable-parallel $GACODE_PAR_OTHER_ARGS --disable-shared --enable-static $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild gacode par
    fi
  fi

}

# For easy switching
buildGacode() {
  techo "For GACODE, PREFER_CMAKE = $PREFER_CMAKE."
  # if $PREFER_CMAKE; then
  if false; then
    buildGacodeCM
  else
    buildGacodeAT
  fi
}

######################################################################
#
# Test gacode
#
######################################################################

testGacode() {
  techo "Not testing gacode."
}

######################################################################
#
# Install gacode
#
######################################################################

installGacode() {
  bilderInstall -r gacode ser
  bilderInstall -r gacode par
  # techo exit; exit
}


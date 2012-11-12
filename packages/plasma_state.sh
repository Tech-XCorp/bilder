#!/bin/bash
#
# Version and build information for Plasma_state
#
# $Id: plasma_state.sh 5734 2012-04-08 14:03:51Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PLASMA_STATE_BLDRVERSION=${PLASMA_STATE_BLDRVERSION:-"2.7.0-r214"}
PLASMA_STATE_TAR_BLDRVERSION=${PLASMA_STATE_TAR_BLDRVERSION:-"1.0.2"}

######################################################################
#
# Other values
#
######################################################################

PLASMA_STATE_BUILDS=${PLASMA_STATE_BUILDS:-"ser"}
addBenBuild plasma_state
PLASMA_STATE_DEPS=pspline,netlib_lite,netcdf,hdf5
PLASMA_STATE_UMASK=002

######################################################################
#
# Launch plasma_state builds.
#
######################################################################

buildPlasma_state() {
  # The tarball is in ftpkgs
# Check for svn version or package
  if test -d $PROJECT_DIR/plasma_state; then
    getVersion -l plasma_state plasma_state
    bilderPreconfig plasma_state
    res=$?
  else
    PLASMA_STATE_BLDRVERSION=$PLASMA_STATE_TAR_BLDRVERSION
    bilderUnpack plasma_state
    res=$?
  fi

  if test $res = 0; then

# Tone down optimization for xl
    case $CC in
      xlc* | */xlc*)
        PS_COMPFLAGS_SER="$CONFIG_COMPFLAGS_SER --with-optimization=minimal"
        PS_COMPFLAGS_PAR="$CONFIG_COMPFLAGS_PAR --with-optimization=minimal"
        ;;
      *)
        PS_COMPFLAGS_SER="$CONFIG_COMPFLAGS_SER"
        PS_COMPFLAGS_PAR="$CONFIG_COMPFLAGS_PAR"
        ;;
    esac

# Use compiler wrappers for actual make
    local PS_MAKE_COMPILERS_SER="CC='\$(abs_top_builddir)/txutils/cc' CXX='\$(abs_top_builddir)/txutils/cxx' FC='\$(abs_top_builddir)/txutils/f90' F77='\$(abs_top_builddir)/txutils/f77'"
    local PS_MAKE_COMPILERS_BEN="CC='\$(abs_top_builddir)/txutils/cc' CXX='\$(abs_top_builddir)/txutils/cxx' FC='\$(abs_top_builddir)/txutils/f90' F77='\$(abs_top_builddir)/txutils/f77'"

# Build everything
    if bilderConfig plasma_state ser "$CONFIG_COMPILERS_SER $PS_COMPFLAGS_SER $PLASMA_STATE_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild plasma_state ser "$PS_MAKE_COMPILERS_SER $PLASMA_STATE_MAKE_ARGS"
    fi
    if bilderConfig plasma_state ben "$CONFIG_COMPILERS_BEN $PS_COMPFLAGS_PAR --enable-back-end-node $PLASMA_STATE_BEN_OTHER_ARGS $CONFIG_SUPRA_SP_ARG"; then
      bilderBuild plasma_state ben "$PS_MAKE_COMPILERS_BEN $PLASMA_STATE_MAKE_ARGS"
    fi
  fi
}

######################################################################
#
# Test Plasma_state
#
######################################################################

testPlasma_state() {
  techo "Not testing plasma_state."
}

######################################################################
#
# Install Plasma_state
#
######################################################################

installPlasma_state() {
# Set umask to allow only group to modify
  bilderInstall plasma_state ser plasma_state
  bilderInstall plasma_state ben plasma_state-ben
}


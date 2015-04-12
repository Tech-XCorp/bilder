#!/bin/bash
#
# Version and build information for Plasma_state
#
# $Id$
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
# Looks like this was for building on LCFs but as of Mar 29 2014 the compiler
# wrappers no longer exist (?) Pletzer.
    local PS_MAKE_COMPILERS_SER=""
    if test -f '\$abs_top_builddir)/txutils/cc'; then
       PS_MAKE_COMPILERS_SER="CC='\$(abs_top_builddir)/txutils/cc'"
    fi
    if test -f '\$(abs_top_builddir)/txutils/cxx'; then
       PS_MAKE_COMPILERS_SER="$PS_MAKE_COMPILERS_SER CXX='\$(abs_top_builddir)/txutils/cxx'"
    fi
    if test -f '\$(abs_top_builddir)/txutils/f90'; then
       PS_MAKE_COMPILERS_SER="$PS_MAKE_COMPILERS_SER FC='\$(abs_top_builddir)/txutils/f90'"
    fi
    if test -f '\$(abs_top_builddir)/txutils/f77'; then
       PS_MAKE_COMPILERS_SER="$PS_MAKE_COMPILERS_SER F77='\$(abs_top_builddir)/txutils/f77'"
    fi

    local PS_MAKE_COMPILERS_BEN="CC='\$(abs_top_builddir)/txutils/cc' CXX='\$(abs_top_builddir)/txutils/cxx' FC='\$(abs_top_builddir)/txutils/f90' F77='\$(abs_top_builddir)/txutils/f77'"

    if [ -z "$MDSPLUS_LIBDIR" ]; then
      PLASMA_STATE_MDS="--disable-mdsplus"
    else
      PLASMA_STATE_MDS="--with-mdsplus-libdir=$MDSPLUS_LIBDIR"
    fi

    case `uname` in
     Linux)
      PLASMA_STATE_EXTRA_LIBS="LIBS=-ldl"
    esac
# Build everything
    if bilderConfig plasma_state ser "$CONFIG_COMPILERS_SER $PS_COMPFLAGS_SER $PLASMA_STATE_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG $PLASMA_STATE_MDS" plasma_state $PLASMA_STATE_EXTRA_LIBS ;then
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


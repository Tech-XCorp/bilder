#!/bin/bash
#
# Version and build information for txbase
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# NOTE: txbase is set to the following tarball version so that if a
# project does not have txbase as an external repo, then this tarball
# will be used instead. If you want to use the repo, make sure you have
# txbase an external.

TXBASE_BLDRVERSION=${TXBASE_BLDRVERSION:-"2.9.1-r516"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$TXBASE_DESIRED_BUILDS"; then
  TXBASE_DESIRED_BUILDS=ser,par,sersh
fi
computeBuilds txbase
addCc4pyBuild txbase
# Deps include autotools for configuring tests
TXBASE_DEPS=hdf5,Python,openmpi,cmake,autotools
case `uname` in
  CYGWIN*)
    TXBASE_DEPS=$TXBASE_DEPS,boost
    ;;
esac
trimvar TXBASE_DEPS ','
TXBASE_MASK=002
TXBASE_TESTDATA=txbresults
TXBASE_TESTNAME=${TXBASE_TESTNAME:-"TxbTests"}

######################################################################
#
# Launch txbase builds.
#
######################################################################

buildTxbase() {

# Check for svn version or package
  if test -d $PROJECT_DIR/txbase; then
    getVersion txbase
    bilderPreconfig -c txbase
    res=$?
  else
    bilderUnpack txbase
    res=$?
  fi
  TXBASE_MAKE_ARGS="$TXBASE_MAKEJ_ARGS"

# Regular build
  if test $res = 0; then

    local BUILD_SHARED_LIBS_FLAG=
    case `uname` in
# This was failing on Windows.  Need to check.
      Darwin | Linux) BUILD_SHARED_LIBS_FLAG=-DBUILD_SHARED_LIBS:BOOL=TRUE;;
      CYGWIN*) BUILD_SHARED_LIBS_FLAG=-DBUILD_SHARED_LIBS:BOOL=TRUE;;
    esac

# All builds
    if bilderConfig -c txbase ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $BOOST_INCDIR_ARG $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SER_OTHER_ARGS"; then
      bilderBuild txbase ser "$TXBASE_MAKE_ARGS"
    fi
    if bilderConfig -c txbase par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $BOOST_INCDIR_ARG $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_PAR_OTHER_ARGS"; then
      bilderBuild txbase par "$TXBASE_MAKE_ARGS"
    fi
# These are static libs, but linked against shared hdf5 so we do not get
# line-time errors in composertoolkit.
    if bilderConfig -c txbase sersh "$BUILD_SHARED_LIBS_FLAG -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DUSE_SHARED_HDF5:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $BOOST_INCDIR_ARG $CMAKE_HDF5_SERSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SERSH_OTHER_ARGS"; then
      bilderBuild txbase sersh "$TXBASE_MAKE_ARGS"
    fi
    if bilderConfig -c txbase parsh "-DENABLE_PARALLEL:BOOL=TRUE $BUILD_SHARED_LIBS_FLAG -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE -DUSE_SHARED_HDF5:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $BOOST_INCDIR_ARG $CMAKE_HDF5_PARSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_PARSH_OTHER_ARGS"; then
      bilderBuild txbase parsh "$TXBASE_MAKE_ARGS"
    fi
    if bilderConfig -c txbase cc4py "-DBUILD_WITH_CC4PY_RUNTIME:BOOL=TRUE -DUSE_CC4PY_HDF5:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_HDF5_CC4PY_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_CC4PY_OTHER_ARGS"; then
      bilderBuild txbase cc4py "$TXBASE_MAKE_ARGS"
    fi

  fi

}

######################################################################
#
# Test txbase
#
######################################################################

testTxbase() {
  bilderRunTests txbase ${TXBASE_TESTNAME}
}

######################################################################
#
# Install txbase
#
######################################################################

installTxbase() {
  bilderInstallTestedPkg -r -p open txbase ${TXBASE_TESTNAME}
  # techo "WARNING: Quitting at end of txbase.sh."; cleanup
}


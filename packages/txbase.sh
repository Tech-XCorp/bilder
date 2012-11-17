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

TXBASE_BLDRVERSION=${TXBASE_BLDRVERSION:-"2.9.1-r516"}

######################################################################
#
# Builds, deps, mask, auxdata, paths
#
######################################################################

if test -z "$TXBASE_BUILDS"; then
  TXBASE_BUILDS=ser,par
  case `uname` in
    CYGWIN*)
      TXBASE_BUILDS=$TXBASE_BUILDS,sersh,parsh
      ;;
    *)
      case `uname -n` in
        eugene*);;
        *) addCc4pyBuild txbase;;
      esac
      ;;
  esac
  trimvar TXBASE_BUILDS ','
fi
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

# All builds
    if bilderConfig -c txbase ser "$CMAKE_NODEFLIB_FLAGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $BOOST_INCDIR_ARG $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SER_OTHER_ARGS"; then
      bilderBuild txbase ser "$TXBASE_MAKE_ARGS"
    fi
    if bilderConfig -c txbase par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_NODEFLIB_FLAGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $BOOST_INCDIR_ARG $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_PAR_OTHER_ARGS"; then
      bilderBuild txbase par "$TXBASE_MAKE_ARGS"
    fi
# These are static libs, but linked against shared hdf5 so we do not get
# line-time errors in composertoolkit.
    if bilderConfig -c txbase sersh "-DUSE_SHARED_HDF5:BOOL=TRUE -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $BOOST_INCDIR_ARG $CMAKE_HDF5_SERSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SERSH_OTHER_ARGS"; then
      bilderBuild txbase sersh "$TXBASE_MAKE_ARGS"
    fi
    if bilderConfig -c txbase parsh "-DENABLE_PARALLEL:BOOL=TRUE -DUSE_SHARED_HDF5:BOOL=TRUE -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $BOOST_INCDIR_ARG $CMAKE_HDF5_PARSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_PARSH_OTHER_ARGS"; then
      bilderBuild txbase parsh "$TXBASE_MAKE_ARGS"
    fi
    if bilderConfig -c txbase cc4py "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_HDF5_CC4PY_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_CC4PY_OTHER_ARGS"; then
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
  bilderRunTests txbase TxbTests
}

######################################################################
#
# Install txbase
#
######################################################################

installTxbase() {
  bilderInstallTestedPkg -r -p open txbase TxbTests
  # techo "WARNING: Quitting at end of txbase.sh."; cleanup
}


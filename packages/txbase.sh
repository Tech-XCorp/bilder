#!/bin/bash
#
# Build information for txbase
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in txbase_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/txbase_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTxbaseNonTriggerVars() {
  TXBASE_MASK=002
# This allows individual package control of testing
  TXBASE_TESTING=${TXBASE_TESTING:-"${TESTING}"}
# This allows individual package control over whether ctest is used
  TXBASE_USE_CTEST=${TXBASE_USE_CTEST:-"$BILDER_USE_CTEST"}
# This allows individual package control over ctest submission model
  TXBASE_CTEST_MODEL=${TXBASE_CTEST_MODEL:-"$BILDER_CTEST_MODEL"}
}
setTxbaseNonTriggerVars

######################################################################
#
# Launch txbase builds.
#
######################################################################

buildTxbase() {

# Check for svn version or package
  if test -d $PROJECT_DIR/txbase; then
    getVersion txbase
    if ! bilderPreconfig -c txbase; then
      return
    fi
  else
    if ! bilderUnpack txbase; then
      return
    fi
  fi

# Make targets modified according to testing
  local TXBASE_ADDL_ARGS=
  local TXBASE_MAKE_ARGS=
  local TXBASE_DEVELDOCS_MAKE_ARGS=apidocs-force
  TXBASE_MAKE_ARGS="$TXBASE_MAKE_ARGS $TXBASE_MAKEJ_ARGS"
  trimvar TXBASE_MAKE_ARGS ' '
  if $TXBASE_USE_CTEST; then
    TXBASE_ADDL_ARGS="-DCTEST_BUILD_FLAGS:STRING='$TXBASE_MAKE_ARGS'"
    TXBASE_MAKE_ARGS="$TXBASE_MAKEJ_ARGS ${TXBASE_CTEST_MODEL}Build"
    TXBASE_DEVELDOCS_MAKE_ARGS="${TXBASE_CTEST_MODEL}Build"
  fi

# Force full link path
  TXBASE_SER_OTHER_ARGS="${TXBASE_SER_OTHER_ARGS} -DBUILD_SHARED=FALSE"
  TXBASE_PYCSH_OTHER_ARGS="${TXBASE_PYCSH_OTHER_ARGS} -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
  TXBASE_SERSH_OTHER_ARGS="${TXBASE_SERSH_OTHER_ARGS} -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
  TXBASE_PARSH_OTHER_ARGS="${TXBASE_PARSH_OTHER_ARGS} -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
  TXBASE_PAR_OTHER_ARGS="${TXBASE_PAR_OTHER_ARGS} -DBUILD_SHARED=FALSE"
  if [[ `uname` =~ CYGWIN ]]; then
      if echo "$CMAKE_COMPILERS_SER" | grep -q "icl"; then 
	  TXBASE_SER_OTHER_ARGS="${TXBASE_SER_OTHER_ARGS} -DCMAKE_STATIC_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt' -DCMAKE_EXE_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt'"
      fi
      if echo "$CMAKE_COMPILERS_PAR" | grep -q "mpiicc"; then
	  TXBASE_PAR_OTHER_ARGS="${TXBASE_PAR_OTHER_ARGS} -DCMAKE_STATIC_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt' -DCMAKE_EXE_LINKER_FLAGS:STRING='/NODEFAULTLIB:msvcrt' -DMPI_HEADER_PATH:PATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/include'  -DMPI_DIR:PATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/'  -DMPI_INCLUDE_PATH:PATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/include' -DMPI_LIBRARY:FILEPATH:FILEPATH='C:/Program Files (x86)/Intel/MPI/5.0.3.048/intel64/lib/release_mt/impi.lib'"
      fi
  fi

# All builds
  if bilderConfig -c txbase ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_ADDL_ARGS $TXBASE_SER_OTHER_ARGS"; then
    bilderBuild txbase ser "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase sersh "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SERSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_ADDL_ARGS $TXBASE_SERSH_OTHER_ARGS"; then
    bilderBuild txbase sersh "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TXBASE_ADDL_ARGS $CMAKE_SUPRA_SP_ARG $TXBASE_SER_OTHER_ARGS"; then
    bilderBuild txbase sermd "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase pycst "-DUSE_PYC_LIBS:BOOL=TRUE -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_HDF5_PYCST_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_ADDL_ARGS $TXBASE_PYCST_OTHER_ARGS"; then
    bilderBuild txbase pycst "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase pycsh "-DUSE_PYC_LIBS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_HDF5_PYCSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_ADDL_ARGS $TXBASE_PYCSH_OTHER_ARGS"; then
    bilderBuild txbase pycsh "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_ADDL_ARGS $TXBASE_PAR_OTHER_ARGS"; then
    bilderBuild txbase par "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase parsh "-DENABLE_PARALLEL:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PARSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_ADDL_ARGS $TXBASE_PARSH_OTHER_ARGS"; then
    bilderBuild txbase parsh "$TXBASE_MAKE_ARGS"
  fi
  if bilderConfig -c txbase ben "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $CMAKE_HDF5_BEN_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_ADDL_ARGS $TXBASE_BEN_OTHER_ARGS"; then
# ben builds not tested
    bilderBuild txbase ben "$TXBASE_MAKE_ARGS"
  fi

# Developer doxygen (develdocs) build: requires nmake on cygwin, no j args
  local TXBASE_DEVELDOCS_MAKER_ARGS=
  if [[ `uname` =~ CYGWIN ]]; then
    TXBASE_DEVELDOCS_MAKER_ARGS="-m nmake"
  fi
  if bilderConfig -I $DEVELDOCS_DIR $TXBASE_DEVELDOCS_MAKER_ARGS txbase develdocs "-DCTEST_BUILD_TARGET:STRING=apidocs-force -DENABLE_DEVELDOCS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $TXBASE_SER_OTHER_ARGS" txbase; then
    bilderBuild $TXBASE_DEVELDOCS_MAKER_ARGS txbase develdocs "$TXBASE_DEVELDOCS_MAKE_ARGS"
  fi

}

######################################################################
#
# Test txbase
#
######################################################################

testTxbase() {
  local testtarg=test
  $TXBASE_USE_CTEST && testtarg="${TXBASE_CTEST_MODEL}Test"
  bilderRunTests -bs -i ben txbase "" "${testtarg}"
}

######################################################################
#
# Install txbase
#
######################################################################

installTxbase() {
  TXBASE_DEVELDOCS_INSTALL_TARGET=install-apidocs
  bilderInstallTestedPkg -b -i ben -a "-r -p open" txbase
}


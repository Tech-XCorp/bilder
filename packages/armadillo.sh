#!/bin/bash
#
# Build information for armadillo
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in armadillo_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/armadillo_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setArmadilloNonTriggerVars() {
  ARMADILLO_MASK=002
# This allows individual package control of testing
  ARMADILLO_TESTING=${ARMADILLO_TESTING:-"${TESTING}"}
# This allows individual package control over whether ctest is used
  ARMADILLO_USE_CTEST=${ARMADILLO_USE_CTEST:-"$BILDER_USE_CTEST"}
# This allows individual package control over ctest submission model
  ARMADILLO_CTEST_MODEL=${ARMADILLO_CTEST_MODEL:-"$BILDER_CTEST_MODEL"}
}
setArmadilloNonTriggerVars

######################################################################
#
# Launch armadillo builds.
#
######################################################################

buildArmadillo() {

# Check for svn version or package
  if test -d $PROJECT_DIR/armadillo; then
    getVersion armadillo
    if ! bilderPreconfig -c armadillo; then
      return
    fi
  else
    if ! bilderUnpack armadillo; then
      return
    fi
  fi

# Make targets modified according to testing
  local ARMADILLO_ADDL_ARGS=
  local ARMADILLO_MAKE_ARGS=
  local ARMADILLO_DEVELDOCS_MAKE_ARGS=apidocs-force
  ARMADILLO_MAKE_ARGS="$ARMADILLO_MAKE_ARGS $ARMADILLO_MAKEJ_ARGS"
  trimvar ARMADILLO_MAKE_ARGS ' '
  if $ARMADILLO_USE_CTEST; then
    ARMADILLO_ADDL_ARGS="-DCTEST_BUILD_FLAGS:STRING='$ARMADILLO_MAKE_ARGS'"
    ARMADILLO_MAKE_ARGS="$ARMADILLO_MAKEJ_ARGS ${ARMADILLO_CTEST_MODEL}Build"
    ARMADILLO_DEVELDOCS_MAKE_ARGS="${ARMADILLO_CTEST_MODEL}Build"
  fi

# Force full link path
  ARMADILLO_SER_OTHER_ARGS="${ARMADILLO_SER_OTHER_ARGS}"
  ARMADILLO_PYCSH_OTHER_ARGS="${ARMADILLO_PYCSH_OTHER_ARGS} -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
  ARMADILLO_SERSH_OTHER_ARGS="${ARMADILLO_SERSH_OTHER_ARGS} -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
  ARMADILLO_PARSH_OTHER_ARGS="${ARMADILLO_PARSH_OTHER_ARGS} -DCMAKE_INSTALL_RPATH_USE_LINK_PATH:BOOL=TRUE"
  ARMADILLO_PAR_OTHER_ARGS="${ARMADILLO_PAR_OTHER_ARGS}"

# All builds
  if bilderConfig -c armadillo ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SER_DIR_ARG $CMAKE_SUPRA_SP_ARG $ARMADILLO_ADDL_ARGS $ARMADILLO_SER_OTHER_ARGS"; then
    bilderBuild armadillo ser "$ARMADILLO_MAKE_ARGS"
  fi
  if bilderConfig -c armadillo sersh "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_HDF5_SERSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $ARMADILLO_ADDL_ARGS $ARMADILLO_SERSH_OTHER_ARGS"; then
    bilderBuild armadillo sersh "$ARMADILLO_MAKE_ARGS"
  fi
  if bilderConfig -c armadillo sermd "-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $ARMADILLO_ADDL_ARGS $CMAKE_SUPRA_SP_ARG $ARMADILLO_SER_OTHER_ARGS"; then
    bilderBuild armadillo sermd "$ARMADILLO_MAKE_ARGS"
  fi
  if bilderConfig -c armadillo pycst "-DUSE_PYC_LIBS:BOOL=TRUE -DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_HDF5_PYCST_DIR_ARG $CMAKE_SUPRA_SP_ARG $ARMADILLO_ADDL_ARGS $ARMADILLO_PYCST_OTHER_ARGS"; then
    bilderBuild armadillo pycst "$ARMADILLO_MAKE_ARGS"
  fi
  if bilderConfig -c armadillo pycsh "-DUSE_PYC_LIBS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_HDF5_PYCSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $ARMADILLO_ADDL_ARGS $ARMADILLO_PYCSH_OTHER_ARGS"; then
    bilderBuild armadillo pycsh "$ARMADILLO_MAKE_ARGS"
  fi
  if bilderConfig -c armadillo par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $ARMADILLO_ADDL_ARGS $ARMADILLO_PAR_OTHER_ARGS"; then
    bilderBuild armadillo par "$ARMADILLO_MAKE_ARGS"
  fi
  if bilderConfig -c armadillo parsh "-DENABLE_PARALLEL:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PARSH_DIR_ARG $CMAKE_SUPRA_SP_ARG $ARMADILLO_ADDL_ARGS $ARMADILLO_PARSH_OTHER_ARGS"; then
    bilderBuild armadillo parsh "$ARMADILLO_MAKE_ARGS"
  fi
  if bilderConfig -c armadillo ben "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $CMAKE_HDF5_BEN_DIR_ARG $CMAKE_SUPRA_SP_ARG $ARMADILLO_ADDL_ARGS $ARMADILLO_BEN_OTHER_ARGS"; then
# ben builds not tested
    bilderBuild armadillo ben "$ARMADILLO_MAKE_ARGS"
  fi

}

######################################################################
#
# Test armadillo
#
######################################################################

testArmadillo() {
  techo "Not testing armadillo"
}

######################################################################
#
# Install armadillo
#
######################################################################

installArmadillo() {
  bilderInstallTestedPkg -b -i ben -a "-r -p open" armadillo
}


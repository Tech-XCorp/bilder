#!/bin/bash
#
# Version and build information for gras
#
# $Id$
#
######################################################################

######################################################################
#
# Version and finding.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/gras_aux.sh

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setGrasGlobalVars() {
  GRAS_BUILDS=${GRAS_BUILDS:-"sersh"}
  GRAS_DEPS=geant4
  addtopathvar PATH $CONTRIB_DIR/gras-sersh/bin
}
setGrasGlobalVars

######################################################################
#
# Launch gras builds.
#
######################################################################

buildGras() {

# Determine whether to build
  if ! bilderUnpack -c gras; then
    return
  fi

# Some envvars
  G4INSTALL="$CONTRIB_DIR/geant4-sersh"
  export G4INSTALL
  source $G4INSTALL/bin/geant4.sh
  GRAS_ENV="$GRAS_ENV G4INSTALL='$G4INSTALL'"

# Get library names
  local libpost=
  local libpre=
  case `uname` in
    CYGWIN*)
      libpost=lib
      ;;
    Darwin)
      libpre=lib
      libpost=dylib
      ;;
    Linux)
      libpre=lib
      libpost=so
      ;;
  esac
  local xercescdir="${CONTRIB_DIR}/xercesc-sersh"

  GRAS_ADDL_ARGS="${GRAS_ADDL_ARGS} -DXERCESC_INCLUDE_DIR:PATH='${xercescdir}/include' -DXERCESC_LIBRARY:FILEPATH='${xercescdir}/lib/${libpre}xerces-c.$libpost' -DGeant4_DIR:PATH='$CONTRIB_DIR/geant4/lib/Geant4-9.6.2' -DGRAS_INSTALL_PREFIX:PATH='$CONTRIB_DIR/gras'"

  if bilderConfig -c gras sersh "$GRAS_ADDL_ARGS $CMAKE_SUPRA_SP_ARG"; then
    bilderBuild gras sersh "" "$GRAS_ENV"
  fi
}

######################################################################
#
# Test gras
#
######################################################################

testGras() {
  techo "Not testing gras."
}

######################################################################
#
# Install gras
#
######################################################################

installGras() {
  bilderInstallAll gras
  findGras
}


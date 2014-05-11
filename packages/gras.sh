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
  GRAS_BUILDS=${GRAS_BUILDS:-"$FORPYTHON_BUILD"}
  GRAS_DEPS=geant4
  addtopathvar PATH $CONTRIB_DIR/gras-$FORPYTHON_BUILD/bin
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
  G4INSTALL="$CONTRIB_DIR/geant4-$FORPYTHON_BUILD"
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
  local xercescdir="${CONTRIB_DIR}/xercesc-$FORPYTHON_BUILD"

  GRAS_CONFIG_ARGS="${GRAS_CONFIG_ARGS} -DXERCESC_INCLUDE_DIR:PATH='${xercescdir}/include' -DXERCESC_LIBRARY:FILEPATH='${xercescdir}/lib/${libpre}xerces-c.$libpost' -DGeant4_DIR:PATH='$GEANT4_SERSH_CMAKE_DIR' -DGRAS_INSTALL_PREFIX:PATH='$CONTRIB_DIR/gras-${GRAS_BLDRVERSION}-$FORPYTHON_BUILD'"
  if bilderConfig -c gras $FORPYTHON_BUILD "$GRAS_CONFIG_ARGS"; then
    bilderBuild gras $FORPYTHON_BUILD "" "$GRAS_ENV"
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


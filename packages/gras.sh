#!/bin/bash
#
# Build information for gras
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in gras_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/gras_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setGrasNonTriggerVars() {
  GRAS_UMASK=002
}
setGrasNonTriggerVars

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
  G4INSTALL="$CONTRIB_DIR/geant4-$FORPYTHON_SHARED_BUILD"
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
  local xercescdir="${CONTRIB_DIR}/xercesc-$FORPYTHON_SHARED_BUILD"
  local GRAS_CONFIG_ARGS="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"

  GRAS_CONFIG_ARGS="${GRAS_CONFIG_ARGS} -DXERCESC_INCLUDE_DIR:PATH='${xercescdir}/include' -DXERCESC_LIBRARY:FILEPATH='${xercescdir}/lib/${libpre}xerces-c.$libpost' -DGeant4_DIR:PATH='$GEANT4_SERSH_CMAKE_DIR' -DGRAS_INSTALL_PREFIX:PATH='$CONTRIB_DIR/gras-${GRAS_BLDRVERSION}-$FORPYTHON_SHARED_BUILD'"
  if bilderConfig -c gras $FORPYTHON_SHARED_BUILD "$GRAS_CONFIG_ARGS"; then
    bilderBuild gras $FORPYTHON_SHARED_BUILD "" "$GRAS_ENV"
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
}


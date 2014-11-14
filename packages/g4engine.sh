#!/bin/bash
#
# Build information for g4engine
#
# $Id: g4engine.sh 1870 2014-11-13 14:44:34Z jrobcary $
#
######################################################################

######################################################################
#
# Version
#
# Putting the version information into g4engine_aux.sh eliminates the
# rebuild when one changes that file.  Of course, if the actual version
# changes, or this file changes, there will be a rebuild.  But with
# this one can change the experimental version without causing a rebuild
# in a non-experimental Bilder run.  One can also change any auxiliary
# functions without sparking a build.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/g4engine_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setDagmcNonTriggerVars() {
  G4ENGINE_UMASK=002
}
setDagmcNonTriggerVars

######################################################################
#
# Launch g4engine builds.
#
######################################################################

#
# Build G4ENGINE
#
buildG4engine() {

# Preconfigure g4engine
  getVersion g4engine
  if ! bilderPreconfig g4engine; then
    return
  fi

# hdf5 found from environment
#  G4ENGINE_ENV="HDF5_ROOT='$HDF5_SERSH_DIR'"
# Moab found from config file
#  G4ENGINE_ADDL_ARGS="-DMOAB_CMAKE_CONFIG:PATH='$MOAB_SERSH_CMAKE_DIR'"
# Geant found from build directory
#  G4ENGINE_ADDL_ARGS="$G4ENGINE_ADDL_ARGS -DBUILD_GEANT4=ON -DGEANT4_DIR:PATH='$BUILD_DIR/geant4-$GEANT4_BLDRVERSION/sersh'"

# If not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$G4ENGINE_MAKEJ_ARGS"
  fi

# Bilder build
  local otherargsvar=`genbashvar G4ENGINE_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig $makerargs g4engine $FORPYTHON_SHARED_BUILD "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_SUPRA_SP_ARG $G4ENGINE_ADDL_ARGS $G4ENGINE_OTHER_ARGS" "" "$G4ENGINE_ENV"; then
    bilderBuild $makerargs g4engine $FORPYTHON_SHARED_BUILD "$makejargs" "$G4ENGINE_ENV"
  fi

}

######################################################################
#
# Test g4engine
#
######################################################################

testG4engine() {
  techo "Not testing g4engine."
}

######################################################################
#
# Install g4engine
#
######################################################################

installG4engine() {
  bilderInstallAll g4engine
}


#!/bin/sh
######################################################################
#
# @file    dagmc.sh
#
# @brief   Build information for dagmc.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
# Putting the version information into dagmc_aux.sh eliminates the
# rebuild when one changes that file.  Of course, if the actual version
# changes, or this file changes, there will be a rebuild.  But with
# this one can change the experimental version without causing a rebuild
# in a non-experimental Bilder run.  One can also change any auxiliary
# functions without sparking a build.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/dagmc_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setDagmcNonTriggerVars() {
  DAGMC_UMASK=002
}
setDagmcNonTriggerVars

######################################################################
#
# Launch dagmc builds.
#
######################################################################

#
# Build DAGMC
#
buildDagMc() {

# Get dagmc from repo and remove any detritus
  updateRepo dagmc
  rm -f $PROJECT_DIR/dagmc/CMakeLists.txt.{orig,rej}

# Get dagmc
  cd $PROJECT_DIR
  if ! test -d dagmc; then
    techo "ERROR: [$FUNCNAME] dagmc not found."
    return
  fi
  getVersion dagmc
  if ! bilderPreconfig dagmc; then
    return
  fi

#
# Gotta love the variation
#
# hdf5 found from environment
  DAGMC_ENV="HDF5_ROOT='$HDF5_SERSH_DIR'"
# Moab found from config file
  DAGMC_ADDL_ARGS="-DMOAB_CMAKE_CONFIG:PATH='$MOAB_SERSH_CMAKE_DIR'"
# Geant found from build directory
  # DAGMC_ADDL_ARGS="$DAGMC_ADDL_ARGS -DBUILD_GEANT4=ON -DGEANT4_DIR:PATH='$BUILD_DIR/geant4-$GEANT4_BLDRVERSION/sersh'"
  DAGMC_ADDL_ARGS="$DAGMC_ADDL_ARGS -DBUILD_GEANT4=ON -DGEANT4_DIR:PATH='$GEANT4_SERSH_CMAKE_DIR'"

# If not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$DAGMC_MAKEJ_ARGS"
  fi

# Bilder build
  local otherargsvar=`genbashvar DAGMC_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig $makerargs dagmc $FORPYTHON_SHARED_BUILD "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_SUPRA_SP_ARG $DAGMC_ADDL_ARGS $DAGMC_OTHER_ARGS" "" "$DAGMC_ENV"; then
    bilderBuild $makerargs dagmc $FORPYTHON_SHARED_BUILD "$makejargs" "$DAGMC_ENV"
  fi

}

######################################################################
#
# Test dagmc
#
######################################################################

testDagMc() {
  techo "Not testing dagmc."
}

######################################################################
#
# Install dagmc
#
######################################################################

installDagMc() {
  bilderInstallAll dagmc
}


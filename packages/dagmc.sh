#!/bin/bash
#
# Version and build information for dagmc
#
# $Id$
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
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setDagMcGlobalVars() {
# Only the python build needed.
  DAGMC_BUILD=$FORPYTHON_BUILD
  DAGMC_BUILDS=${DAGMC_BUILDS:-"$FORPYTHON_BUILD"}
  DAGMC_DEPS=geant4,moab
  DAGMC_UMASK=002
}
setDagMcGlobalVars

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

# If not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$DAGMC_MAKEJ_ARGS"
  fi

# Configure and build
  if bilderConfig $makerargs dagmc $DAGMC_BUILD "-DBUILD_SHARED_LIBS:BOOL=TRUE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $CMAKE_SUPRA_SP_ARG $DAGMC_ADDL_ARGS $DAGMC_OTHER_ARGS" "" "$DAGMC_ENV"; then
    bilderBuild $makerargs dagmc $DAGMC_BUILD "$makejargs" "$DAGMC_ENV"
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
  findDagMc
}

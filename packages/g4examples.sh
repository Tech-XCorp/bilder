#!/bin/bash
#
# Build information for g4examples
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in g4examples_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/g4examples_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setG4examplesNonTriggerVars() {
  G4EXAMPLES_UMASK=002
# This allows individual package control of testing
  G4EXAMPLES_TESTING=${G4EXAMPLES_TESTING:-"${TESTING}"}
# This allows individual package control over whether ctest is used
  G4EXAMPLES_USE_CTEST=${G4EXAMPLES_USE_CTEST:-"$BILDER_USE_CTEST"}
# This allows individual package control over ctest submission model
  G4EXAMPLES_CTEST_MODEL=${G4EXAMPLES_CTEST_MODEL:-"$BILDER_CTEST_MODEL"}
}
setG4examplesNonTriggerVars

######################################################################
#
# Launch g4examples builds.
#
######################################################################

# Configure and build serial and parallel
buildG4examples() {

# Get version and see if anything needs building
  getVersion g4examples
  if ! bilderPreconfig g4examples; then
    return
  fi

# Make targets modified according to testing
  local G4EXAMPLES_ADDL_ARGS=
  local G4EXAMPLES_MAKE_ARGS="all DagMCQuickStart-pdf"
  if $G4EXAMPLES_USE_CTEST; then
    G4EXAMPLES_ADDL_ARGS="-DCTEST_BUILD_FLAGS:STRING='$G4EXAMPLES_MAKE_ARGS'"
    G4EXAMPLES_MAKE_ARGS="${G4EXAMPLES_CTEST_MODEL}Build"
  fi

# Figure out g4engine version
  if test -d $PROJECT_DIR/g4engine; then
    getVersion g4engine
    for val in MAJOR MINOR PATCH; do
      eval G4ENGINE_VERSION_$val=`grep "set(VERSION_$val" $PROJECT_DIR/g4engine/CMakeLists.txt | sed -e 's/").*$//' -e 's/^.*"//'`
    done
    G4ENGINE_PROJVERSION=${G4ENGINE_VERSION_MAJOR}.${G4ENGINE_VERSION_MINOR}.${G4ENGINE_VERSION_MINOR}
    G4EXAMPLES_ADDL_ARGS="$G4EXAMPLES_ADDL_ARGS -DG4ENGINE_PROJVERSION:STRING=${G4ENGINE_PROJVERSION} -DG4ENGINE_BLDRVERSION=${G4ENGINE_BLDRVERSION}"
  fi

# The examples are installed in BLDR_INSTALL_DIR, not USERDOCS_DIR, as we
# do not want them rsync'd over to the depot.
# Cygwin docs must be made with nmake (cannot be parallel as jom would do)
  G4EXAMPLES_MAKER_ARGS=
  if [[ `uname` =~ CYGWIN ]]; then
   G4EXAMPLES_MAKER_ARGS="-m nmake"
  fi
  if bilderConfig $G4EXAMPLES_MAKER_ARGS g4examples lite "-DVPEX_STANDALONE:BOOL=TRUE $CMAKE_SUPRA_SP_ARG $G4EXAMPLES_ADDL_ARGS $G4EXAMPLES_OTHER_ARGS"; then
    bilderBuild $G4EXAMPLES_MAKER_ARGS g4examples lite "$G4EXAMPLES_MAKE_ARGS"
  fi

}

######################################################################
#
# Test
#
######################################################################

# Set umask to allow only group to modify
testG4examples() {
  bilderRunTests -s -i lite g4examples "" "${G4EXAMPLES_CTEST_MODEL}Test"
}

######################################################################
#
# Install
#
######################################################################

installG4examples() {
  bilderInstallTestedPkg g4examples "" "$G4EXAMPLES_MAKER_ARGS"
}


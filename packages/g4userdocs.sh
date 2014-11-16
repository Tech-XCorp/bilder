#!/bin/bash
#
# Build information for g4userdocs
#
# $Id: g4userdocs.sh 1250 2014-06-24 23:14:32Z cary $
#
######################################################################

######################################################################
#
# Trigger variables set in g4userdocs_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/g4userdocs_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setG4userdocsNonTriggerVars() {
  G4USERDOCS_UMASK=002
# This allows individual package control of testing
  G4USERDOCS_TESTING=${G4USERDOCS_TESTING:-"${TESTING}"}
# This allows individual package control over whether ctest is used
  G4USERDOCS_USE_CTEST=${G4USERDOCS_USE_CTEST:-"$BILDER_USE_CTEST"}
# This allows individual package control over ctest submission model
  G4USERDOCS_CTEST_MODEL=${G4USERDOCS_CTEST_MODEL:-"$BILDER_CTEST_MODEL"}
}
setG4userdocsNonTriggerVars

######################################################################
#
# Launch g4userdocs builds.
#
######################################################################

# Configure and build
buildG4userdocs() {

# Get version and see if anything needs building
  getVersion g4userdocs
  local g4udirs=$BLDR_INSTALL_DIR
  if [[ $G4USERDOCS_BUILDS =~ (^|,)url(,|$) ]]; then
    g4udirs=$g4udirs,$USERDOCS_DIR
  fi
  if ! bilderPreconfig -I $g4udirs g4userdocs; then
    return
  fi

# Make targets modified according to testing
  local G4USERDOCS_ADDL_ARGS=
  local G4USERDOCS_MAKE_ARGS=userdocs
  if $G4USERDOCS_USE_CTEST; then
    G4USERDOCS_ADDL_ARGS="-DCTEST_BUILD_FLAGS:STRING='$G4USERDOCS_MAKE_ARGS'"
    G4USERDOCS_MAKE_ARGS="${G4USERDOCS_CTEST_MODEL}Build"
  fi

# Figure out g4engine version
  if test -d $PROJECT_DIR/g4engine; then
    getVersion g4engine
    for val in MAJOR MINOR PATCH; do
      eval G4ENGINE_VERSION_$val=`grep "set(VERSION_$val" $PROJECT_DIR/g4engine/CMakeLists.txt | sed -e 's/").*$//' -e 's/^.*"//'`
    done
    G4ENGINE_PROJVERSION=${G4ENGINE_VERSION_MAJOR}.${G4ENGINE_VERSION_MINOR}.${G4ENGINE_VERSION_MINOR}
    G4USERDOCS_ADDL_ARGS="$G4USERDOCS_ADDL_ARGS -DG4ENGINE_PROJVERSION:STRING=${G4ENGINE_PROJVERSION} -DG4ENGINE_BLDRVERSION=${G4ENGINE_BLDRVERSION}"
  fi

# Cygwin docs must be made with nmake (cannot be parallel as jom would do)
  G4USERDOCS_MAKER_ARGS=
  if [[ `uname` =~ CYGWIN ]]; then
    G4USERDOCS_MAKER_ARGS="-m nmake"
  fi

# Docs build with various MathJax's.
# Only the url build is put in USERDOCS_DIR, as only it is to be rync'd
# over to the depot.
  if bilderConfig $G4USERDOCS_MAKER_ARGS g4userdocs lite "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $G4USERDOCS_ADDL_ARGS $G4USERDOCS_LITE_OTHER_ARGS"; then
    bilderBuild $G4USERDOCS_MAKER_ARGS g4userdocs lite "$G4USERDOCS_MAKE_ARGS"
  fi
  if bilderConfig $G4USERDOCS_MAKER_ARGS g4userdocs full "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG -DSPHINX_DEBUG:BOOL=TRUE $G4USERDOCS_ADDL_ARGS $G4USERDOCS_FULL_OTHER_ARGS"; then
    bilderBuild $G4USERDOCS_MAKER_ARGS g4userdocs full "$G4USERDOCS_MAKE_ARGS"
  fi
# The URL build (for putting on line) is installed under $USERDOCS_DIR
# for easy rsyncing.  We keep the last 10 versions.
  if test -d $USERDOCS_DIR; then
    $BILDER_DIR/cleaninstalls.sh -lrR -k 10 $USERDOCS_DIR
  fi
  getSphinxMathArg
  if bilderConfig -I $USERDOCS_DIR $G4USERDOCS_MAKER_ARGS g4userdocs url "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $SPHINX_MATHARG $G4USERDOCS_ADDL_ARGS $G4USERDOCS_URL_OTHER_ARGS"; then
    bilderBuild $G4USERDOCS_MAKER_ARGS g4userdocs url "$G4USERDOCS_MAKE_ARGS"
  fi

}

######################################################################
#
# Test
#
######################################################################

# Set umask to allow only group to modify
testG4userdocs() {
  bilderRunTests -s -i lite,url,full g4userdocs "" "${G4USERDOCS_CTEST_MODEL}Test"
}

######################################################################
#
# Install
#
######################################################################

installG4userdocs() {
  bilderInstallTestedPkg g4userdocs "" "-r $G4USERDOCS_MAKER_ARGS"
}


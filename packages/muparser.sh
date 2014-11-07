#!/bin/bash
#
# Build information for muparser
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in muparser_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/muparser_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMuparserNonTriggerVars() {
  MUPARSER_UMASK=002
}
setMuparserNonTriggerVars

######################################################################
#
# Launch muparser builds.
#
######################################################################

buildMuparser() {

# Unpack or return
  if ! bilderUnpack muparser; then
    return
  fi

# Set flags
  local MUPARSER_SER_CMAKE_ARGS=
  local MUPARSER_SERMD_CMAKE_ARGS="-DBUILD_WITH_SHARED_RUNTIME=TRUE"
  local MUPARSER_SERSH_CMAKE_ARGS="-DBUILD_SHARED_LIBS=TRUE"
  local configargs=
  local makerargs=
  # serial build
  if bilderConfig -c muparser ser "$MUPARSER_SER_CMAKE_ARGS}"; then
     bilderBuild muparser ser
  fi
  # shared build
  if bilderConfig -c muparser sersh "$MUPARSER_SERSH_CMAKE_ARGS}"; then
     bilderBuild muparser sersh
  fi
  if [[ `uname` =~ CYGWIN ]]; then 
     # build with shared runtime
     if bilderConfig -c muparser sermd "$MUPARSER_SERMD_CMAKE_ARGS}"; then
         bilderBuild muparser sermd
     fi
  fi 

}

######################################################################
#
# Test muparser
#
######################################################################

testMuparser() {
  techo "Not testing muparser."
}

######################################################################
#
# Install muparser
#
######################################################################

installMuparser() {
  local makerargs=
# No install target on Windows
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m :"
    for bld in `echo $MUPARSER_BUILDS | tr ',' ' '`; do
      cmd="mkdir -p $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/lib"
      techo "$cmd"
      $cmd
    done
  fi
  for bld in `echo $MUPARSER_BUILDS | tr ',' ' '`; do
    local sfx=
    test $bld != ser && sfx="-${bld}"
    if bilderInstall $makerargs muparser $bld; then
      if [[ `uname` =~ CYGWIN ]]; then
# Manual install on Windows
        cmd="mkdir -p $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/lib"
        techo "$cmd"
        $cmd
        cmd="cd $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/build"
        techo "$cmd"
        $cmd
        cmd="cp -r $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/$bld/muparser.lib $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld/lib"
        techo "$cmd"
        $cmd
        cmd="cp -r $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/include $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld"
        techo "$cmd"
        $cmd
      fi
    else
# Should remove only if a build was attempted and failed to install
# Disable for now.
      if false; then
      # if [[ `uname` =~ CYGWIN ]]; then
        cmd="rm -rf $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-$bld"
        techo "$cmd"
        $cmd
      fi
    fi
  done
}


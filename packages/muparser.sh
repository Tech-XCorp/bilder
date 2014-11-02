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

  case `uname` in
    CYGWIN*)
# The build on Windows is just an "nmake -fmakefile.vc"
# and then manually installing the includes and library
      cmd="cd $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/build"
      $cmd
      cmd="nmake -fmakefile.vcmt"
      $cmd
      cmd="mkdir -p $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-ser"
      $cmd
      cmd="cp -r $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/lib $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-ser"
      $cmd
      cmd="cp -r $BUILD_DIR/muparser-${MUPARSER_BLDRVERSION}/include $CONTRIB_DIR/muparser-${MUPARSER_BLDRVERSION}-ser"
      $cmd
      cmd="mkLink $CONTRIB_DIR muparser-${MUPARSER_BLDRVERSION}-ser muparser"
      $cmd
      cmd="$BILDER_DIR/setinstald.sh -i $CONTRIB_DIR muparser,ser"
      $cmd
      buildSuccesses="$buildSuccesses muparser"
      ;;
    Darwin | Linux)
      if bilderConfig muparser ser "--enable-shared=no"; then
        bilderBuild muparser ser
      fi
      if bilderConfig muparser sersh "--enable-shared=yes"; then
        bilderBuild muparser sersh
      fi
      ;;
  esac
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
  case `uname` in
    Darwin | Linux) bilderInstallAll muparser;;
  esac
}


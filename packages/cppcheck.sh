#!/bin/bash
#
# Build information for cppcheck
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in cppcheck_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/cppcheck_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCppcheckNonTriggerVars() {
  :
}
setCppcheckNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildCppcheck() {
  CPPCHECK_CONFIG_METHOD=none
  if ! bilderUnpack -i cppcheck; then
    return
  fi
# create cfg subdir
  local instdir=$CONTRIB_DIR/cppcheck-${CPPCHECK_BLDRVERSION}-ser
  cmd="/usr/bin/install -d -m775 $instdir/cfg"
  techo "$cmd"
  $cmd
# No configure step, so must set build dir
  CPPCHECK_SER_BUILD_DIR=$BUILD_DIR/cppcheck-$CPPCHECK_BLDRVERSION/ser
  local makerargs=
  local cppcheckenv=
  if [[ `uname` =~ Linux ]]; then
    cppcheckenv="LD_RUN_PATH=$CONTRIB_DIR/pcre/lib:$LD_RUN_PATH"
  fi
  bilderBuild -kD $makerargs cppcheck ser "CFGDIR=$CONTRIB_DIR/cppcheck-${CPPCHECK_BLDRVERSION}-ser/cfg HAVE_RULES=yes" "$cppcheckenv"
}

######################################################################
#
# Test
#
######################################################################

testCppcheck() {
  techo "Not testing cppcheck."
}

######################################################################
#
# Install cppcheck
#
######################################################################

installCppcheck() {
# No configure step, so must set installation dir
  CPPCHECK_SER_INSTALL_DIR=$CONTRIB_DIR
  local exesfx=
  if [[ `uname` =~ CYGWIN ]]; then
    exesfx=.exe
  fi
  if bilderInstall -L -m ":" cppcheck ser; then
    local cmd=
    local instdir=$CONTRIB_DIR/cppcheck-${CPPCHECK_BLDRVERSION}-ser
    cmd="/usr/bin/install -d -m775 $instdir/bin/subdir"
    techo "$cmd"
    $cmd
    cd $BUILD_DIR/cppcheck-$CPPCHECK_BLDRVERSION/ser
    cmd="/usr/bin/install -m775 cppcheck${exesfx} $instdir/bin"
    techo "$cmd"
    $cmd
    cmd="/usr/bin/install -m775 cfg/* $instdir/cfg"
    techo "$cmd"
    $cmd
    cmd="(cd $CONTRIB_DIR/bin; ln -sf ../cppcheck-${CPPCHECK_BLDRVERSION}-ser/bin/cppcheck$exesfx cppcheck$exesfx )"
    techo "$cmd"
    eval "$cmd"
  fi
}


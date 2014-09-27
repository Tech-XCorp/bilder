#!/bin/bash
#
# Build information for tdd
#
# From http://software.intel.com/en-us/intel-tbb
# tar xzf tbb43_20140724oss_src.tgz
# mv tbb41_20140724oss tbb-41_20140724oss
# COPY_EXTENDED_ATTRIBUTES_DISABLE=1 tar czf tbb-43_20140724oss.tar.gz tbb-43_20140724oss
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in tdd_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/tdd_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setTddNonTriggerVars() {
  TDD_UMASK=002
}
setTddNonTriggerVars

######################################################################
#
# Launch tdd builds.
#
######################################################################

buildTdd() {

# tdd has no build/configure system
  TDD_CONFIG_METHOD=NONE
  if bilderUnpack -i tdd; then
    for bld in `echo $TDD_BUILDS | sed 's/,/ /g'`; do
      local builddirvar=`genbashvar $1-$bld`_BUILD_DIR
      eval $builddirvar=$BUILD_DIR/tdd-$TDD_BLDRVERSION/$bld
      bilderBuild tdd $bld
    done
  fi

}

######################################################################
#
# Test tdd
#
######################################################################

testTdd() {
  techo "Not testing tdd."
}

######################################################################
#
# Install tdd
#
######################################################################

installTdd() {
  bilderInstallAll tdd
  # for bld in `echo $TDD_BUILDS | sed 's/,/ /g'`; do
     # bilderInstall tdd $bld
  # done
}


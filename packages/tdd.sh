#!/bin/bash
#
# Version and build information for tdd.
#
# From http://software.intel.com/en-us/intel-tbb
# tar xzf tbb41_20130314oss_src.tgz
# mv tbb41_20130314oss tbb-41_20130314oss
# COPY_EXTENDED_ATTRIBUTES_DISABLE=1 tar czf tbb-41_20130314oss.tgz tbb-41_20130314oss
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

TDD_BLDRVERSION=${TDD_BLDRVERSION:-"41_20130314oss"}

######################################################################
#
# Other values
#
######################################################################

TDD_BUILDS=${TDD_BUILDS:-"ser,sersh"}
addCc4pyBuild tdd
TDD_DEPS=

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
      local builddirvar=`genbashvar $1-$bld`__BUILD_DIR
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
  for bld in `echo $TDD_BUILDS | sed 's/,/ /g'`; do
    bilderInstall tdd $bld
  done
}


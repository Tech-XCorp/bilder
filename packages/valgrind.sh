#!/bin/bash
#
# Version and build information for valgrind
#
# $Id: valgrind.sh 6956 2012-11-07 14:38:46Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

VALGRIND_BLDRVERSION_STD=3.8.1
VALGRIND_BLDRVERSION_EXP=3.8.1

######################################################################
#
# Builds, deps, mask, auxdata, paths
#
######################################################################

VALGRIND_BUILDS=${VALGRIND_BUILDS:-"ser"}
VALGRIND_DEPS=
VALGRIND_MASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/valgrind/bin

######################################################################
#
# Launch valgrind builds.
#
######################################################################

buildValgrind() {

# VALGRIND must be built in place
  if bilderUnpack -i valgrind; then
# Test for unpacked as ser
    if test -d $BUILD_DIR/valgrind-$VALGRIND_BLDRVERSION/ser; then
      cmd="cd $BUILD_DIR/valgrind-$VALGRIND_BLDRVERSION/ser"
      techo "$cmd"
      $cmd
      if test -x autogen.sh; then
        cmd="./autogen.sh"
        techo "$cmd"
        $cmd
      fi
      cd -
      if bilderConfig -i valgrind ser; then
        bilderBuild valgrind ser
      fi
    fi
  fi

}

######################################################################
#
# Test valgrind
#
######################################################################

testValgrind() {
  techo "Not testing valgrind."
}

######################################################################
#
# Install valgrind
#
######################################################################

installValgrind() {

  if bilderInstall valgrind ser valgrind; then
    : # Put post build commands here.
  fi

}


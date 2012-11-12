#!/bin/bash
#
# Version and build information for eigen3
#
# $Id: eigen3.sh 6121 2012-05-26 16:05:40Z cary $
#
# To fix the package:
#
# tar xjf ../numpkgs/eigen3-6e7488e20373.tar.bz2
# mv eigen3-6e7488e20373 eigen3-3.0.5
# find eigen3-3.0.5 -name "._*" -delete
# tar cjf ../numpkgs/eigen3-3.0.5.tar.bz2  eigen3-3.0.5
#
######################################################################

######################################################################
#
# Version
#
######################################################################

EIGEN3_BLDRVERSION=${EIGEN3_BLDRVERSION:-"3.0.5"}

######################################################################
#
# Other values
#
######################################################################

EIGEN3_BUILDS=${EIGEN3_BUILDS:-"NONE"}
EIGEN3_DEPS=bzip2
EIGEN3_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/eigen3/bin

######################################################################
#
# Launch eigen3 builds.
#
######################################################################

buildEigen3() {

# If worked, preigen3ed to configure and build
  if bilderUnpack eigen3; then

# Configure and build
    if bilderConfig eigen3 ser "$EIGEN3_OTHER_ARGS"; then
      bilderBuild eigen3 ser "$JMAKEARGS"
    fi

  fi

}

######################################################################
#
# Test eigen3
#
######################################################################

testEigen3() {
  techo "Not testing eigen3."
}

######################################################################
#
# Install eigen3
#
######################################################################

installEigen3() {
  if bilderInstall eigen3 ser; then
    : # Probably need to fix up dylibs here
  fi
  # techo "WARNING: Quitting at end of eigen3.sh."; cleanup
}


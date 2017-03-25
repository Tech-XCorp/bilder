#!/bin/sh
######################################################################
#
# @file    eigen3.sh
#
# @brief   Version and build information for eigen3.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# To fix the package:
#
# tar xjf ../numpkgs/eigen3-6e7488e20373.tar.bz2
# mv eigen3-6e7488e20373 eigen3-3.0.5
# find eigen3-3.0.5 -name "._*" -delete
# env COPYFILE_DISABLE=true tar cjf ../numpkgs/eigen3-3.0.5.tar.bz2  eigen3-3.0.5
# The env prefix is needed on OS X to disable copying of ._ files.
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

EIGEN3_BUILDS=${EIGEN3_BUILDS:-"ser"}
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

    # This makes eigen3 configure/installs more robust as it's
    # not strictly needed.  Had it installing into cuda for some reason
    EIGEN3_OTHER_ARGS="-DEIGEN_BUILD_PKGCONFIG:BOOL=FALSE ${EIGEN3_OTHER_ARGS}"
# Configure and build
    if bilderConfig eigen3 ser "$EIGEN3_OTHER_ARGS"; then
      bilderBuild eigen3 ser "$EIGEN3_MAKEJ_ARGS"
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


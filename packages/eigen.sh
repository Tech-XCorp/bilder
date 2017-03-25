#!/bin/sh
######################################################################
#
# @file    eigen.sh
#
# @brief   Build information for eigen.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in eigen_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/eigen_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setEigenNonTriggerVars() {
  EIGEN_UMASK=002
}
setEigenNonTriggerVars

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/eigen/bin

######################################################################
#
# Launch eigen builds.
#
######################################################################

buildEigen() {

# If worked, preigened to configure and build
  if ! bilderUnpack eigen; then
    return
  fi

# This makes eigen configure/installs more robust as it's
# not strictly needed.  Had it installing into cuda for some reason
  EIGEN_OTHER_ARGS="-DEIGEN_BUILD_PKGCONFIG:BOOL=FALSE ${EIGEN_OTHER_ARGS}"
# Configure and build
  if bilderConfig eigen ser "$EIGEN_OTHER_ARGS"; then
    bilderBuild eigen ser "$EIGEN_MAKEJ_ARGS"
  fi

}

######################################################################
#
# Test eigen
#
######################################################################

testEigen() {
  techo "Not testing eigen."
}

######################################################################
#
# Install eigen
#
######################################################################

installEigen() {
  if bilderInstall eigen ser; then
    : # Probably need to fix up dylibs here
  fi
  # techo "WARNING: Quitting at end of eigen.sh."; cleanup
}


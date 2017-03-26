#!/bin/sh
######################################################################
#
# @file    thrust.sh
#
# @brief   Version and build information for thrust.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

THRUST_BLDRVERSION=${THRUST_BLDRVERSION:-"1.6.0"}
THRUST_DEPS=

######################################################################
#
# Builds and deps
#
######################################################################

THRUST_BUILDS=${THRUST_BUILDS:-"ser"}

######################################################################
#
# Build thrust
#
######################################################################

buildThrust() {

  if bilderUnpack thrust; then
# Try twice for cygwin
    cmd="rmall $CONTRIB_DIR/thrust-${THRUST_BLDRVERSION}"
    echo "$cmd"
    if ! $cmd; then
      echo $cmd
      $cmd
    fi
# Copy to get group correct, as top dir is setgid
    cmd="cp -R thrust-${THRUST_BLDRVERSION} $CONTRIB_DIR"
    echo "$cmd"
    if ! $cmd; then
      techo "thrust failed to install"
      installFailures="$installFailures thrust"
      return
    fi
# Fix any perms
    if ! setOpenPerms $CONTRIB_DIR/thrust-${THRUST_BLDRVERSION}; then
      installFailures="$installFailures thrust"
      return
    fi
    ln -sf $CONTRIB_DIR/thrust-${THRUST_BLDRVERSION} $CONTRIB_DIR/thrust
    ${PROJECT_DIR}/bilder/setinstald.sh -i $CONTRIB_DIR thrust,ser
  fi

}

######################################################################
#
# Test thrust
#
######################################################################

testThrust() {
  techo "Not testing thrust."
}

######################################################################
#
# Install thrust
#
######################################################################

installThrust() {
 :
}


#!/bin/sh
######################################################################
#
# @file    forthon.sh
#
# @brief   Version and build information for Forthon.
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

FORTHON_BLDRVERSION=${FORTHON_BLDRVERSION:-"0.8.4"}

######################################################################
#
# Other values
#
######################################################################

FORTHON_BUILDS=${FORTHON_BUILDS:-"pycsh"}
FORTHON_DEPS=numpy

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/bin

######################################################################
#
# Launch Forthon builds.
#
######################################################################

buildForthon() {
  if bilderUnpack Forthon; then
    bilderDuBuild Forthon
  fi
}

######################################################################
#
# Test Forthon
#
######################################################################

testForthon() {
  techo "Not testing Forthon."
}

######################################################################
#
# Install Forthon
#
######################################################################

installForthon() {
  bilderDuInstall Forthon
}


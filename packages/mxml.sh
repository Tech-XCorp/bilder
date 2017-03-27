#!/bin/sh
######################################################################
#
# @file    mxml.sh
#
# @brief   Version and build information for mxml (mini xml).
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

MXML_BLDRVERSION=${MXML_BLDRVERSION:-"2.6"}

######################################################################
#
# Other values
#
######################################################################

MXML_BUILDS=${MXML_BUILDS:-"ser"}
MXML_DEPS=

######################################################################
#
# Launch mxml builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildMxml() {
  if bilderUnpack -i mxml; then
    if bilderConfig -i mxml ser; then
      bilderBuild mxml ser
    fi
  fi
}

######################################################################
#
# Test mxml
#
######################################################################

testMxml() {
  techo "Not testing mxml."
}

######################################################################
#
# Install mxml
#
######################################################################

installMxml() {
  bilderInstall mxml ser
}


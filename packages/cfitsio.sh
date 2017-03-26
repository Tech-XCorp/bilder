#!/bin/sh
######################################################################
#
# @file    cfitsio.sh
#
# @brief   Version and build information for cfitsio.
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

CFITSIO_BLDRVERSION=${CFITSIO_BLDRVERSION:-"3.280"}

# Built from package only
######################################################################
#
# Other values
#
######################################################################

CFITSIO_BUILDS=${CFITSIO_BUILDS:-"ser"}

######################################################################
#
# Launch cfitsio builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildCfitsio() {
  if bilderUnpack -i cfitsio; then
    if bilderConfig -i -n cfitsio ser; then
      bilderBuild cfitsio ser
    fi
  fi
}

######################################################################
#
# Test cfitsio
#
######################################################################

testCfitsio() {
  techo "Not testing cfitsio."
}

######################################################################
#
# Install cfitsio
#
######################################################################

installCfitsio() {
  bilderInstall cfitsio ser
}


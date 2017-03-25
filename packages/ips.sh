#!/bin/sh
######################################################################
#
# @file    ips.sh
#
# @brief   Version and build information for IPS from swim.
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

# Built from svn repo only

######################################################################
#
# Builds, deps, mask, and paths
#
######################################################################

IPS_BUILDS=${IPS_BUILDS:-"pycsh"}
if test -n "$DOCS_BUILDS"; then
  ips_docs="docs"
else
  ips_docs=""
fi
IPS_DEPS=cmake,numpy,sphinx,dakota
if "$BUILD_FUSION"; then
  IPS_DEPS=${IPS_DEPS},plasma_state
fi
IPS_UMASK=007
addtopathvar PATH $INSTALL_DIR/ips/bin

######################################################################
#
# Launch ips builds.
#
######################################################################

buildIPS() {
  getVersion ips
  if bilderPreconfig ips; then
# Serial build
    if bilderConfig -c ips pycsh " $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $IPS_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG" ips; then
      bilderBuild ips pycsh "all $ips_docs $IPS_MAKEJ_ARGS"
    fi
  fi
}

######################################################################
#
# Test ips
#
######################################################################

# Set umask to allow only group to modify
testIPS() {
  techo "Not testing IPS."
}

######################################################################
#
# Install IPS
#
######################################################################

# Set umask to allow only group to use
installIPS() {
  bilderInstall ips pycsh ips
}


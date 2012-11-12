#!/bin/bash
#
# Version and build information for IPS from swim
#
# $Id: ips.sh 6854 2012-10-17 14:58:41Z cary $
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

IPS_BUILDS=${IPS_BUILDS:-"cc4py"}
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
    if bilderConfig -c ips cc4py " $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $IPS_SER_OTHER_ARGS $CONFIG_SUPRA_SP_ARG" ips; then
      bilderBuild ips cc4py "all $ips_docs $JMAKEARGS"
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
  bilderInstall ips cc4py ips
}


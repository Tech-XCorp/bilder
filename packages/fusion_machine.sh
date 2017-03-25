#!/bin/sh
######################################################################
#
# @file    fusion_machine.sh
#
# @brief   Documentation goes here.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

#!/bin/bash
#
# Version and build information for fusion_machine
#
# $Rev$ $Date$
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
# Builds, deps, mask, auxdata, paths
#
######################################################################

if test -z "$FUSION_MACHINE_BUILDS" -o "$FUSION_MACHINE_BUILDS" != NONE; then
  FUSION_MACHINE_BUILDS="pycsh"
fi
FUSION_MACHINE_DEPS=numpy
addtopathvar PATH $BLDR_INSTALL_DIR/fusion_machine/bin

######################################################################
#
# Launch fusion_machine builds.
#
######################################################################

buildFusion_machine() {

# Set cmake options
  local FUSION_MACHINE_OTHER_ARGS="$FUSION_MACHINE_CMAKE_OTHER_ARGS"

# Configure and build serial and parallel
  getVersion fusion_machine
  if bilderPreconfig fusion_machine; then
# pycsh build
    if bilderConfig -c fusion_machine pycsh "$FUSION_MACHINE_OTHER_ARGS $CMAKE_SUPRA_SP_ARG" fusion_machine; then
      bilderBuild fusion_machine pycsh "$FUSION_MACHINE_MAKEJ_ARGS"
    fi
  fi

}

######################################################################
#
# Test fusion_machine
#
######################################################################

# Set umask to allow only group to modify
testFusion_machine() {
  techo "Not testing fusion_machine."
}

######################################################################
#
# Install fusion_machine
#
######################################################################

installFusion_machine() {
# Install parallel first, then serial last to override utilities
  bilderInstall fusion_machine pycsh fusion_machine
}

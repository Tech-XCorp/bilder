#!/bin/bash
#
# Version and build information for fusion_machine
#
# $Id: fusion_machine.sh 6889 2012-10-25 14:10:23Z cary $
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
  FUSION_MACHINE_BUILDS="cc4py"
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
# cc4py build
    if bilderConfig -c fusion_machine cc4py "$FUSION_MACHINE_OTHER_ARGS $CMAKE_SUPRA_SP_ARG" fusion_machine; then
      bilderBuild fusion_machine cc4py "$JMAKEARGS"
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
  bilderInstall fusion_machine cc4py fusion_machine
}

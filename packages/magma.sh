#!/bin/bash
#
# Version and build information for magma
#
# $Id$
#
######################################################################

MAGMA_BLDRVERSION=${MAGMA_BLDRVERSION:-"1.2.1"}

######################################################################
#
# Other values
#
######################################################################

MAGMA_BUILDS=${MAGMA_BUILDS:-"gpu"}
MAGMA_DEPS=atlas
MAGMA_UMASK=002

#####################################################################
#
# Launch magma builds
#
######################################################################

buildMagma() {
  if bilderUnpack -i magma; then
    MAGMA_CONFIG_METHOD=none
    MAGMA_GPU_INSTALL_DIR=$CONTRIB_DIR
    MAGMA_GPU_BUILD_DIR=$BUILD_DIR/magma-$MAGMA_BLDRVERSION/gpu
    bilderBuild magma gpu "ATLAS_DIR=$CONTRIB_DIR/atlas"
  fi
}

######################################################################
#
# Test magma
#
######################################################################

testMagma() {
  # wait for build before testing it
  waitBuild magma-$MAGMA_BUILDS

  # run one of MAGMA's tests on the GPU
  testing/testing_cgelqf_gpu -M 1024 -N 1024
}

######################################################################
#
# Install magma
#
######################################################################

installMagma() {
  MAGMA_GPU_INSTALL_SUBDIR=magma-$MAGMA_BLDRVERSION-$MAGMA_BUILDS
  bilderInstall magma gpu "magma" "prefix=$CONTRIB_DIR/$MAGMA_GPU_INSTALL_SUBDIR"
}

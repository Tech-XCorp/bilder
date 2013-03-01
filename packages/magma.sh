#!/bin/bash
#
# Version and build information for magma
#
# $Id$
#
######################################################################

MAGMA_BLDRVERSION=${MAGMA_BLDRVERSION:-"1.3.0-tx"}

######################################################################
#
# Other values
#
######################################################################

MAGMA_BUILDS=${MAGMA_BUILDS:-"gpu"}
case `uname` in
 Linux)
  if $LINK_WITH_MKL; then
    MAGMA_DEPS=
  else
    MAGMA_DEPS=atlas
  fi
  ;;
 Darwin)
  MAGMA_DEPS=
  ;;
esac
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

    case `uname` in
     Linux)
      if $LINK_WITH_MKL; then
        bilderBuild magma gpu "GPU_TARGET=Fermi MAKEINC_SUFFIX=linux-mkl"
      else
        bilderBuild magma gpu "GPU_TARGET=Fermi MAKEINC_SUFFIX=linux-atlas BLAS_DIR=$CONTRIB_DIR/atlas"
      fi
      ;;
     Darwin)
      bilderBuild magma gpu "GPU_TARGET=Fermi MAKEINC_SUFFIX=osx"
      ;;
    esac
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
    case `uname` in
     Linux)
      if $LINK_WITH_MKL; then
        bilderInstall magma gpu "magma" "GPU_TARGET=Fermi MAKEINC_SUFFIX=linux-mkl prefix=$CONTRIB_DIR/$MAGMA_GPU_INSTALL_SUBDIR"
      else
        bilderInstall magma gpu "magma" "GPU_TARGET=Fermi MAKEINC_SUFFIX=linux-atlas prefix=$CONTRIB_DIR/$MAGMA_GPU_INSTALL_SUBDIR"
      fi
      ;;
     Darwin)
      bilderInstall magma gpu "magma" "GPU_TARGET=Fermi MAKEINC_SUFFIX=osx prefix=$CONTRIB_DIR/$MAGMA_GPU_INSTALL_SUBDIR"
      ;;
    esac
}

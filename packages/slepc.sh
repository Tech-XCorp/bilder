#!/bin/sh
######################################################################
#
# @file    slepc.sh
#
# @brief   Version and build information for slepc.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
######################################################################

SLEPC_BLDRVERSION=${SLEPC_BLDRVERSION:-"3.1-p6"}

######################################################################
#
# Other values
#
######################################################################

SLEPC_BUILDS=${SLEPC_BUILDS:-"ser,par,pardbg"}
SLEPC_DEPS=petsc
SLEPC_UMASK=002

if $BUILD_PETSCCOMPLEX; then
  SLEPC_BUILDS=${SLEPC_BUILDS}",sercplx,parcplx,parcplxdbg"
fi

######################################################################
#
# Launch slepc builds.
#
######################################################################

buildSlepc() {

  if bilderUnpack -i slepc; then

    # save PETSC_DIR so it can be restored
    PETSC_DIR_SAVE=${PETSC_DIR}

    # serial build
    # slepc configure needs PETSC_DIR set in the environment
    findContribPackage petsc petsc ser
    export PETSC_DIR=${PETSC_SER_DIR}

    if bilderConfig -i -l slepc ser; then
      # Since we don't install petsc with an arch, slepc needs the following
      bilderBuild slepc ser "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/ser PETSC_ARCH=installed-petsc"
    fi

    # par build
    # slepc configure needs PETSC_DIR set in the environment
    findContribPackage petsc petsc par
    export PETSC_DIR=${PETSC_PAR_DIR}

    if bilderConfig -i -l slepc par; then
      # Since we don't install petsc with an arch, slepc needs the following
      bilderBuild slepc par "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/par PETSC_ARCH=installed-petsc"
    fi

    # pardbg build
    # slepc configure needs PETSC_DIR set in the environment
    findContribPackage petsc petsc pardbg
    export PETSC_DIR=${PETSC_PARDBG_DIR}

    if bilderConfig -i -l slepc pardbg; then
      # Since we don't install petsc with an arch, slepc needs the following
      bilderBuild slepc pardbg "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/pardbg PETSC_ARCH=installed-petsc"
    fi

    # serial build
    # slepc configure needs PETSC_DIR set in the environment
    # This directory name is special since the serial complex petsc build is petsc-cplx
    findContribPackage petsc petsc cplx
    export PETSC_DIR=${PETSC_CPLX_DIR}

    if bilderConfig -i -l slepc sercplx; then
      # Since we don't install petsc with an arch, slepc needs the following
      bilderBuild slepc sercplx "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/sercplx PETSC_ARCH=installed-petsc"

    fi

    # par build
    # slepc configure needs PETSC_DIR set in the environment
    findContribPackage petsc petsc parcplx
    export PETSC_DIR=${PETSC_PARCPLX_DIR}

    if bilderConfig -i -l slepc parcplx; then
      # Since we don't install petsc with an arch, slepc needs the following
      bilderBuild slepc parcplx "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/parcplx PETSC_ARCH=installed-petsc"
    fi

    # pardbg build
    # slepc configure needs PETSC_DIR set in the environment
    findContribPackage petsc petsc parcplxdbg
    export PETSC_DIR=${PETSC_PARCPLXDBG_DIR}

    if bilderConfig -i -l slepc parcplxdbg; then
      # Since we don't install petsc with an arch, slepc needs the following
      bilderBuild slepc parcplxdbg "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/parcplxdbg PETSC_ARCH=installed-petsc"
    fi

    # restore PETSC_DIR
    export PETSC_DIR=${PETSC_DIR_SAVE}

  fi

}

######################################################################
#
# Test slepc
#
######################################################################

testSlepc() {
  techo "Not testing slepc."
}

######################################################################
#
# Install slepc
#
######################################################################

installSlepc() {

# Get installation directory.  Should be set above.
  instdirvar=SLEPC_INSTALL_DIR
  instdirval=`deref $instdirvar`
  if test -z "$instdirval"; then
    instdirval=$CONTRIB_DIR
  fi

  # Save PETSC_DIR so it can be restored
  PETSC_DIR_SAVE=${PETSC_DIR}

  # slepc needs PETSC_DIR set in the environment for make install
  export PETSC_DIR=${PETSC_SER_DIR}
  bilderInstall slepc ser slepc "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/ser PETSC_ARCH=installed-petsc"
  ser_installed=$?

  # slepc needs PETSC_DIR set in the environment for make install
  export PETSC_DIR=${PETSC_PAR_DIR}
  bilderInstall slepc par slepc-par  "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/par PETSC_ARCH=installed-petsc"
  par_installed=$?

  # slepc needs PETSC_DIR set in the environment for make install
  export PETSC_DIR=${PETSC_PARDBG_DIR}
  bilderInstall slepc pardbg slepc-pardbg "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/pardbg PETSC_ARCH=installed-petsc"
  pardbg_installed=$?

  # slepc needs PETSC_DIR set in the environment for make install
  export PETSC_DIR=${PETSC_CPLX_DIR}
  bilderInstall slepc sercplx slepc-cplx "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/sercplx PETSC_ARCH=installed-petsc"
  sercplx_installed=$?

  # slepc needs PETSC_DIR set in the environment for make install
  export PETSC_DIR=${PETSC_PARCPLX_DIR}
  bilderInstall slepc parcplx slepc-parcplx  "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/parcplx PETSC_ARCH=installed-petsc"
  parcplx_installed=$?

  # slepc needs PETSC_DIR set in the environment for make install
  export PETSC_DIR=${PETSC_PARCPLXDBG_DIR}
  bilderInstall slepc parcplxdbg slepc-parcplxdbg "SLEPC_DIR=$BUILD_DIR/slepc-$SLEPC_BLDRVERSION/parcplxdbg PETSC_ARCH=installed-petsc"
  parcplxdbg_installed=$?

  # restore PETSC_DIR
  export PETSC_DIR=${PETSC_DIR_SAVE}

}


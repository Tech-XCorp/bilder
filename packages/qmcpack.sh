#!/bin/sh
######################################################################
#
# @file    qmcpack.sh
#
# @brief   Version and build information for qmcpack.
#
# @version $Rev: 3599 $ $Date: 2017-04-07 16:13:04 -0600 (Fri, 07 Apr 2017) $
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables and versions set in qmcpack_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/qmcpack_aux.sh


######################################################################
#
# Version
#
######################################################################

QMCPACK_BLDRVERSION=${QMCPACK_BLDRVERSION:-"3.0.0"}

######################################################################
#
# Builds and deps
#
######################################################################

# QMCPACK_BUILDS=${QMCPACK_BUILDS:-"ser,par"}
QMCPACK_BUILDS=${QMCPACK_BUILDS:-"ser,par"}
echo "QMCPACK_BUILDS=${QMCPACK_BUILDS}"
QMCPACK_DEPS=fftw,fftw3,$MPI_BUILD,lapack,hdf5


######################################################################
#
# Launch qmcpack builds.
#
######################################################################

buildQmcpack() {

  if bilderUnpack qmcpack; then

   techo "==========================================================================================="
   techo " Will run bilder build step (if unpack-ed)"
   techo " TARBALL_NODEFLIB_FLAGS = $TARBALL_NODEFLIB_FLAGS"
   techo "==========================================================================================="

    if bilderConfig -c qmcpack ser "$TARBALL_NODEFLIB_FLAGS $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild qmcpack ser "$QMCPACK_MAKEJ_ARGS"
    fi
    if bilderConfig -c qmcpack par "-DENABLE_PARALLEL:BOOL=TRUE $TARBALL_NODEFLIB_FLAGS $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild qmcpack par "$QMCPACK_MAKEJ_ARGS"
    fi
  fi

}


######################################################################
#
# Install qmcpack
#
######################################################################

installQmcpack() {
  techo "Will run bilder install steps for QMCPack"
  bilderInstall qmcpack ser qmcpack
  bilderInstall qmcpack par qmcpack-par
}


######################################################################
#
# Test Qmcpack
#
######################################################################

testQmcpack() {
  techo "Not testing QMCPACK."
}

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

  # NOTE: all variables for make cmd line need ' ' quotes so other
  # args in line are parsed correctly

  # Specific variables for QMCPACK 'by-hand' make files
  #  QMCPACK_OTHER_ARGS="LMP_INC='-DQMCPACK_GZIP' JPG_INC='' JPG_PATH='' JPG_LIB=''"

  #
  # Serial flags ( CC/LINK is defined by qmcpack make system)
  #
  # QMCPACK_SER_ARGS="CC=$CXX LINK=$CXX"

  #
  # Par flags (check mpi version) ( CC/LINK is defined by qmcpack make system)
  #
  #  QMCPACK_PAR_ARGS="\
  #    FFT_INC='-DFFT_FFTW -I$CONTRIB_DIR/fftw-par/include' \

  # Status
  techo "QMCPACK_SER_ARGS = $QMCPACK_SER_ARGS"
  techo "QMCPACK_PAR_ARGS = $QMCPACK_PAR_ARGS"

  # Builds
  if bilderUnpack qmcpack; then
    techo "Will run bilder build step (unpack)"
  fi
}


######################################################################
#
# Install qmcpack
#
######################################################################

installQmcpack() {
  techo "Will run bilder install steps"
}


######################################################################
#
# Test Qmcpack
#
######################################################################

testQmcpack() {
  techo "Not testing QMCPACK."
}

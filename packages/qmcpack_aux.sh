#!/bin/sh
######################################################################
#
# @file    qmcpack_aux.sh
#
# @brief   Trigger vars and find information for qmcpack.
#
# @version $Rev: 3588 $ $Date: 2017-04-04 11:01:32 -0600 (Tue, 04 Apr 2017) $
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setQmcpackTriggerVars() {

######################################################################
#
# Version
#
######################################################################

QMCPACK_BLDRVERSION=${QMCPACK_BLDRVERSION:-"3.0.0"}

######################################################################
#
# Other values
#
######################################################################

# QMCPACK has both serial and parallel builds
# $QMCPACK_BUILDS=${QMCPACK_BUILDS:-"ser,par"}
QMCPACK_BUILDS=${QMCPACK_BUILDS:-"par"}
QMCPACK_DEPS=fftw,fftw3,$MPI_BUILD,lapack,boost,hdf5
}
setQmcpackTriggerVars


######################################################################
#
# Find qmcpack
#
######################################################################

findQmcpack() {
  findContribPackage Qmcpack qmcpack ser par
}

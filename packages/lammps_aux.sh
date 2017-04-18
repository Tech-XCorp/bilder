#!/bin/sh
######################################################################
#
# @file    lammps_aux.sh
#
# @brief   Trigger vars and find information for lammps.
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

setLammpsTriggerVars() {

######################################################################
#
# Version
#
######################################################################

LAMMPS_BLDRVERSION=${LAMMPS_BLDRVERSION:-"14Aug13"}


######################################################################
#
# Other values
#
######################################################################

# LAMMPS has both serial and parallel builds
LAMMPS_BUILDS=${LAMMPS_BUILDS:-"ser,par"}
LAMMPS_DEPS=fftw,fftw3,$MPI_BUILD,autotools,chrpath
}
setLammpsTriggerVars


######################################################################
#
# Find lammps
#
######################################################################

findLammps() {
  findContribPackage Lammps lammps ser par
}

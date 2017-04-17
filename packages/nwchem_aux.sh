#!/bin/sh
######################################################################
#
# @file    nwchem_aux.sh
#
# @brief   Trigger vars and find information for nwchem.
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

setNwchemTriggerVars() {

######################################################################
#
# Version
#
######################################################################

NWCHEM_BLDRVERSION=${NWCHEM_BLDRVERSION:-"6.6"}

######################################################################
#
# Other values
#
######################################################################

# NWCHEM has both serial and parallel builds
NWCHEM_BUILDS=${NWCHEM_BUILDS:-"par"}
NWCHEM_DEPS=$MPI_BUILD,lapack,Python,chrpath
}
setNwchemTriggerVars


######################################################################
#
# Find nwchem
#
######################################################################

findNwchem() {
  findContribPackage Nwchem nwchem ser par
}

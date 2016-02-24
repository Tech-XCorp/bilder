#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
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

setFftwTriggerVars() {

######################################################################
#
# Version
#
######################################################################

FFTW_BLDRVERSION=${FFTW_BLDRVERSION:-"2.1.5"}

######################################################################
#
# Other values
#
######################################################################

# FFTW has both serial and parallel builds
# TORIC requires only the serial build
# PolySwift requires the parallel build
FFTW_BUILDS=${FFTW_BUILDS:-"ser,par"}
addBenBuild fftw
FFTW_DEPS=$MPI_BUILD
}
setFftwTriggerVars

######################################################################
#
# Find fftw
#
######################################################################

findFftw() {
  findContribPackage Fftw fftw ser par
#  findPycshDir Fftw
##  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/fftw-${FFTW_BLDRVERSION}-par/lib/pkgconfig#
#  printvar PKG_CONFIG_PATH
#  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/fftw-${FFTW_BLDRVERSION}-par/lib
#  printvar LD_LIBRARY_PATH
#  addtopathvar PATH $CONTRIB_DIR/fftw-${FFTW_BLDRVERSION}-par/bin
#  printvar PATH
#  addtopathvar LD_RUN_PATH $CONTRIB_DIR/fftw-${FFTW_BLDRVERSION}-par/lib
#  printvar LD_RUN_PATH
}


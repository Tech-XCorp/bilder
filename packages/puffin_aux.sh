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

setPuffinTriggerVars() {
  PUFFIN_BLDRVERSION_STD=${PUFFIN_BLDRVERSION_STD:-"1.5.2betanw"}
  PUFFIN_BLDRVERSION_EXP=${PUFFIN_BLDRVERSION_EXP:-"1.5.2betanw"}
  if test `uname` = Linux; then
    PUFFIN_BUILDS=${PUFFIN_BUILDS:-"par"}
#    PUFFIN_BUILDS=${PUFFIN_BUILDS:-"par,parmic"}
  fi
  PUFFIN_DEPS="hdf5,fftw,cmake"
}
setPuffinTriggerVars

######################################################################
#
# Find puffin
#
######################################################################

findPuffin() {
  findContribPackage Puffin puffin sersh pycsh
  findPycshDir Puffin
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/puffin-${PUFFIN_BLDRVERSION}-par/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/puffin-${PUFFIN_BLDRVERSION}-par/lib
  printvar LD_LIBRARY_PATH
  addtopathvar PATH $CONTRIB_DIR/puffin-${PUFFIN_BLDRVERSION}-par/bin
  printvar PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/puffin-${PUFFIN_BLDRVERSION}-par/lib
  printvar LD_RUN_PATH
}


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

setElegantTriggerVars() {
  ELEGANT_BLDRVERSION_STD=${ELEGANT_BLDRVERSION_STD:-"29.0Beta5"}
  ELEGANT_BLDRVERSION_EXP=${ELEGANT_BLDRVERSION_EXP:-"29.0Beta5"}
  if test `uname` = Linux; then
    ELEGANT_BUILDS=${ELEGANT_BUILDS:-"ser,par"}
    if test $CUDA_ALL_COMPUTE_CAPABILITIES = "false"; then
      techo "No cuda capabilities on this node, assuming should not build GPU elegant, just CPU."
    else
      techo "Cuda capabilities are available"
      if $SCI_ENABLE_CUDA = "false"; then
        techo "SCI_ENABLE_CUDA flag set to off in bilder command line options. Won't build GPU elegant, just CPU."
      else
        ELEGANT_BUILDS=${ELEGANT_BUILDS:-"sergpu,pargpu"}
      fi
    fi
#    ELEGANT_BUILDS=${ELEGANT_BUILDS:-"ser,sersh,sergpu,par,pargpu"}
  else
    ELEGANT_BUILDS="NONE"
  fi
  ELEGANT_DEPS="hdf5,cmake"
}
setElegantTriggerVars

######################################################################
#
# Find elegant
#
######################################################################

findElegant() {
  findContribPackage Elegant elegant sersh pycsh
  findPycshDir Elegant
  addtopathvar PKG_CONFIG_PATH $CONTRIB_DIR/elegant-${ELEGANT_BLDRVERSION}-par/lib/pkgconfig
  printvar PKG_CONFIG_PATH
  addtopathvar LD_LIBRARY_PATH $CONTRIB_DIR/elegant-${ELEGANT_BLDRVERSION}-par/lib
  printvar LD_LIBRARY_PATH
  addtopathvar PATH $CONTRIB_DIR/elegant-${ELEGANT_BLDRVERSION}-par/bin
  printvar PATH
  addtopathvar LD_RUN_PATH $CONTRIB_DIR/elegant-${ELEGANT_BLDRVERSION}-par/lib
  printvar LD_RUN_PATH
}


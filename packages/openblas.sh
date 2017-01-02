#!/bin/bash
#
# Version and build information for openblas
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in openblas_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/openblas_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOpenblasNonTriggerVars() {
  OPENBLAS_UMASK=002
}
setOpenblasNonTriggerVars

######################################################################
#
# Launch openblas builds.
#
######################################################################

buildOpenblas() {

  if ! bilderUnpack openblas; then
    return
  fi

# OpenBLAS builds ser and sersh by default
  if bilderConfig -c openblas sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $OPENBLAS_SERSH_OTHER_ARGS"; then
    bilderBuild openblas sersh "$OPENBLAS_MAKEJ_ARGS"
  fi
  if bilderConfig -c openblas pycsh "$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $OPENBLAS_PYCSH_OTHER_ARGS"; then
    bilderBuild openblas pycsh "$OPENBLAS_MAKEJ_ARGS"
  fi

}

######################################################################
#
# Test
#
######################################################################

testOpenblas() {
  techo "Not testing openblas."
}

######################################################################
#
# Install openblas
#
######################################################################

# Move the shared openblas libraries to their legacy names.
# Allows shared and static to be installed in same place.
#
# 1: The installation directory
#
installOpenblas() {

# Install one by one and correct
  local instdir
  local openblasinstalled=false

# Static installations first, so static tools can be moved up and saved
# just under bin.
# Remove (-r) old installations.  This assumee that the shared libs
# will subsequently be reinstalled if needed.
  for bld in `echo $OPENBLAS_BUILDS | tr ',' ' '`; do
    if bilderInstall -p open -r openblas $bld; then
      :
    fi
  done

}


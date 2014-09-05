#!/bin/bash
#
# Build information for hypre
# PETSc does not allow serial build w/hypre
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in hypre_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/hypre_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setHypreNonTriggerVars() {
  HYPRE_UMASK=002
}
setHypreNonTriggerVars

######################################################################
#
# Launch hypre builds.
#
######################################################################

buildHypre() {

  if ! bilderUnpack hypre; then
    return 1
  fi

  if bilderConfig -c hypre ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER"; then
    bilderBuild hypre ser
  fi

  if bilderConfig -c hypre sersh "-DHYPRE_SHARED:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER"; then
    bilderBuild hypre sersh
  fi

  if bilderConfig -c hypre par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR"; then
    bilderBuild hypre par
  fi

  if bilderConfig -c hypre parsh "-DHYPRE_SHARED:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR"; then
    bilderBuild hypre parsh
  fi

}

######################################################################
#
# Test hypre
#
######################################################################

testHypre() {
  techo "Not testing hypre."
}

######################################################################
#
# Install hypre
#
######################################################################

installHypre() {
  bilderInstallAll hypre "  -r -p open"
}


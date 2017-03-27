#!/bin/sh
######################################################################
#
# @file    hypre.sh
#
# @brief   Build information for hypre.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# PETSc does not allow serial build w/hypre
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
  local HYPRE_PAR_ADDL_ARGS=
  local HYPRE_PARSH_ADDL_ARGS=
  case `uname` in
    Darwin)
      HYPRE_PARSH_ADDL_ARGS="-DCMAKE_INSTALL_NAME_DIR:STRING='$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-parsh/lib'"
      ;;
  esac

  if bilderConfig -c hypre par "-DHYPRE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-par $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $HYPRE_PAR_ADDL_ARGS $HYPRE_PAR_OTHER_ARGS"; then
    bilderBuild hypre par
  fi

  if bilderConfig -c hypre parsh "-DHYPRE_SHARED:BOOL=ON -DHYPRE_INSTALL_PREFIX:PATH=$CONTRIB_DIR/hypre-${HYPRE_BLDRVERSION}-parsh $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $HYPRE_PARSH_ADDL_ARGS $HYPRE_PARSH_OTHER_ARGS"; then
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


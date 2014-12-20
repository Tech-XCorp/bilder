#!/bin/bash
#
# Build information for graphviz
# PETSc does not allow serial build w/graphviz
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in graphviz_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/graphviz_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setGraphvizNonTriggerVars() {
  GRAPHVIZ_UMASK=002
}
setGraphvizNonTriggerVars

######################################################################
#
# Launch graphviz builds.
#
######################################################################

buildGraphviz() {

  if ! bilderUnpack graphviz; then
    return 1
  fi

  if bilderConfig graphviz ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_PAR --enable-static"; then
    bilderBuild graphviz ser
  fi

}

######################################################################
#
# Test graphviz
#
######################################################################

testGraphviz() {
  techo "Not testing graphviz."
}

######################################################################
#
# Install graphviz
#
######################################################################

installGraphviz() {
  bilderInstallAll graphviz "  -p open"
}


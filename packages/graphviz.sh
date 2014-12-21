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
# --with-gdincludedir=/contrib/libgd-2.1.0-ser/include --with-gdlibdir=/contrib/libgd-2.1.0-ser/lib
# One can find gdlib as above, but that does not get the features, which
# requires gdlib-config.
  local GRAPHVIZ_SER_ADDL_ARGS=
  if test `uname` = Linux; then
    GRAPHVIZ_SER_ADDL_ARGS="--with-extralibdir='$PYTHON_LIBDIR'"
  fi
  if bilderConfig graphviz ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_PAR --enable-static $GRAPHVIZ_SER_ADDL_ARGS $GRAPHVIZ_SER_OTHER_ARGS"; then
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


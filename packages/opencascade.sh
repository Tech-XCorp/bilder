#!/bin/bash
#
# Build information for opencascade
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in opencascade_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/opencascade_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOpenCascadeNonTriggerVars() {
  OPENCASCADE_UMASK=002
}
setOpenCascadeNonTriggerVars

######################################################################
#
# Launch opencascade builds.
#
######################################################################

buildOpenCascade() {
# Unpack
  if ! bilderUnpack opencascade; then
    return 1
  fi
# Build
  if bilderConfig opencascade shared "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $OPENCASCADE_SHARED_ADDL_ARGS $OPENCASCADE_SHARED_OTHER_ARGS"; then
    bilderBuild opencascade shared $opencascademakeflags
  fi
}

######################################################################
#
# Test opencascade
#
######################################################################

testOpenCascade() {
  techo "Not testing opencascade."
}

######################################################################
#
# Install opencascade
#
######################################################################

# Set umask to allow only group to use
installOpenCascade() {
  bilderInstallAll opencascade
}


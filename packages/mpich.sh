#!/bin/bash
#
# Build information for mpich
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in mpich_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/mpich_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMpichNonTriggerVars() {
  MPICH_UMASK=002
}
setMpichNonTriggerVars

######################################################################
#
# Launch mpich builds.
#
######################################################################

buildMpich() {

# Unpack
  if ! bilderUnpack mpich; then
    return 1
  fi

# Configure and build
  mpichmakeflags="$MPICH_MAKEJ_ARGS $mpichmakeflags"

#
# The builds
#

  if bilderConfig mpich static "--enable-static --disable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MPICH_STATIC_ADDL_ARGS $MPICH_STATIC_OTHER_ARGS"; then
    bilderBuild mpich static $mpichmakeflags
  fi

  if bilderConfig mpich shared "--enable-shared --disable-static $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MPICH_SHARED_ADDL_ARGS $MPICH_SHARED_OTHER_ARGS"; then
    bilderBuild mpich shared $mpichmakeflags
  fi

}

######################################################################
#
# Test mpich
#
######################################################################

testMpich() {
  techo "Not testing mpich."
}

######################################################################
#
# Install mpich
#
######################################################################

# Set umask to allow only group to use
installMpich() {
  if test -h $CONTRIB_DIR/mpi; then
    rm -f $CONTRIB_DIR/mpi
  fi
  bilderInstallAll mpich
# static and shared are linked but not mpich directories.  Using static here
  mkLink $CONTRIB_DIR mpich-static mpich
}


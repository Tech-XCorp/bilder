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
# Needed?
  # MPICH_ADDL_ARGS="--enable-romio --enable-smpcoll --with-device=ch3:ssm --with-pm=hydra--with-mpe"

# Configure and build
  mpichmakeflags="$MPICH_MAKEJ_ARGS $mpichmakeflags"

# Builds

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
  bilderInstallAll mpich
}


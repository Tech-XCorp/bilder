#!/bin/bash
#
# Version and build information for mpich
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

if test -z "$MPICH_BLDRVERSION"; then
  MPICH_BLDRVERSION=3.0.4
fi

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if ! [[ `uname` =~ CYGWIN ]]; then
  MPICH_BUILDS=${MPICH_BUILDS:-"static"}
fi
MPICH_DEPS=libtool,automake
MPICH_UMASK=002
# Not adding for now to not conflict with openmpi
# addtopathvar PATH $CONTRIB_DIR/mpich/bin

######################################################################
#
# Launch mpich builds.
#
######################################################################

buildMpich() {

# Unpack
  if ! bilderUnpack mpich; then
    exit 1
  fi
# Needed?
  # MPICH_ADDL_ARGS="--enable-romio --enable-smpcoll --with-device=ch3:ssm --with-pm=hydra--with-mpe"
# Configure and build
  if bilderConfig mpich static "--enable-static --disable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MPICH_ADDL_ARGS $MPICH_OTHER_ARGS"; then
    bilderBuild mpich static
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
  bilderInstall mpich static
}


#!/bin/bash
#
# Version and build information for Adios io library
#
# $Id: adios.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

ADIOS_BLDRVERSION=${ADIOS_BLDRVERSION:-"1.2"}

######################################################################
#
# Other values
#
######################################################################

# Do not change builds unless empty
if test -z "$ADIOS_BUILDS"; then
  ADIOS_BUILDS=ser
  if $BUILD_OPTIONAL; then
    ADIOS_BUILDS=$ADIOS_BUILDS,par
  fi
fi
ADIOS_DEPS=mxml,hdf5,mpi

# Find dependent packages
findContribPackage hdf5 libhdf5.a ser par
findContribPackage mxml libmxml.a ser
findContribPackage openmpi libmpi.a nodl
addtopathvar PATH $OPENMPI_NODL_DIR

# Don't ever chanage a non empty variable
if ! $BUILD_OPTIONAL -a -z "$ADIOS_OTHER_ARGS"; then
  ADIOS_OTHER_ARGS="--with-mxml=$MXML_SER_DIR --with-hdf5=$HDF5_SER_DIR --with-mpi=$OPENMPI_NODL_DIR --with-hdf5-libs='-lhdf5_hl -lhdf5' --enable-fortran=no"
fi

######################################################################
#
# Launch adios builds.
#
######################################################################

# Convention for lower case package is to capitalize only first letter
buildAdios() {
  if bilderUnpack -i adios; then
    if bilderConfig -i adios ser "$ADIOS_OTHER_ARGS"; then
      bilderBuild adios ser
    fi
  fi
}

######################################################################
#
# Test adios
#
######################################################################

testAdios() {
  techo "Not testing adios."
}

######################################################################
#
# Install adios
#
######################################################################

installAdios() {
  bilderInstall adios ser
}


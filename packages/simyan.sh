#!/bin/sh
######################################################################
#
# @file    simyan.sh
#
# @brief   Version and build information for simyan.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

# Built from svn repo only

######################################################################
#
# Builds and deps
#
######################################################################
if test -z "$SIMYAN_BUILDS" -o "$SIMYAN_BUILDS" != NONE; then
    SIMYAN_BUILDS="pycsh"
fi
SIMYAN_DEPS=numpy,dakota

# findBilderTopdir
addtopathvar PATH $BLDR_INSTALL_DIR/simyan/bin

######################################################################
#
# Launch simyan builds.
#
######################################################################

buildSimyan() {

# Set cmake options
  local SIMYAN_OTHER_ARGS="$SIMYAN_CMAKE_OTHER_ARGS"

  # Configure and build serial and parallel
  getVersion simyan
  if bilderPreconfig simyan; then

  SIMYAN_MACHINE_ARGS="-DMPIRUN:STRING=aprun -DNODE_DETECTION:STRING=manual -DCORES_PER_NODE:INTEGER=4 -DSOCKETS_PER_NODE:INTEGER=2 -DNODE_ALLOCATION_MODE:SHARED=shared"
      # Parallel build
      if bilderConfig -c simyan pycsh "$CMAKE_COMPILERS_PYC $SIMYAN_OTHER_ARGS $SIMYAN_MACHINE_ARGS $CMAKE_SUPRA_SP_ARG" simyan; then
          bilderBuild simyan pycsh "$SIMYAN_MAKEJ_ARGS"
      fi

  fi

}

######################################################################
#
# Test simyan
#
######################################################################

# Set umask to allow only group to modify
testSimyan() {
  techo "Not testing simyan."
}

######################################################################
#
# Install polyswift
#
######################################################################

installSimyan() {

# Set umask to allow only group to use on some machines
  um=`umask`
  case $FQMAILHOST in
    *.nersc.gov | *.alcf.anl.gov)
      umask 027
      ;;
    *)
      umask 002
      ;;
  esac

# Install parallel first, then serial last to override utilities
  bilderInstall simyan pycsh simyan

# Revert umask
  umask $um
}

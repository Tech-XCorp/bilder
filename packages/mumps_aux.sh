#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setMumpsTriggerVars() {
  MUMPS_BLDRVERSION_STD=${MUMPS_BLDRVERSION_STD="5.0.2"}
  MUMPS_BLDRVERSION_EXP=${MUMPS_BLDRVERSION_EXP="5.0.2"}
  computeVersion mumps
  case `uname` in
# Neither ser nor par building on Darwin
    Darwin) ;;
    Linux) MUMPS_BUILDS=${MUMPS_BUILDS:-"ser,par"};;
  esac
  MUMPS_DEPS=${MPI_BUILD},lapack,cmake
}
setMumpsTriggerVars

######################################################################
#
# Find mumps
#
######################################################################

findMumps() {
  :
}


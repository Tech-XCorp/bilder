#!/bin/bash
#
# Build information for mumps
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in mumps_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/mumps_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMumpsNonTriggerVars() {
  HYPRE_UMASK=002
  MUMPS_UMASK=002
}
setMumpsNonTriggerVars

#####################################################################
#
# Launch mumps builds
#
######################################################################

buildMumps() {
  if test -d $PROJECT_DIR/mumps; then
    getVersion mumps
    bilderPreconfig -c mumps
    res=$?
  else
    bilderUnpack mumps
    res=$?
  fi

  if bilderConfig mumps ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $MUMPS_SER_OTHER_ARGS $CMAKE_LINLIB_SER_ARGS"; then
    bilderBuild mumps ser
  fi
  if test -z $IMPI_INSTALL_DIR; then
    if bilderConfig mumps par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $MUMPS_PAR_OTHER_ARGS $CMAKE_LINLIB_SER_ARGS"; then
      bilderBuild mumps par
    fi
  else
    if bilderConfig mumps par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $MUMPS_PAR_OTHER_ARGS $CMAKE_LINLIB_SER_ARGS -DMPI_INCLUDE_DIRS:PATH=${IMPI_INSTALL_DIR}/include/ -DMPI_LIBRARIES:PATH=${IMPI_INSTALL_DIR}/lib"; then
      bilderBuild mumps par
    fi
  fi
}

######################################################################
#
# Test mumps
#
######################################################################

testMumps() {
  techo "Not testing mumps."
}

######################################################################
#
# Install mumps
#
######################################################################

installMumps() {
    for build in `echo $MUMPS_BUILDS | tr , " "`; do
      bilderInstall -r mumps $build
    done
}

#!/bin/bash
#
# Version and build information for mumps
#
# $Id$
#
######################################################################

MUMPS_BLDRVERSION=${MUMPS_BLDRVERSION:-"4.10.0"}

######################################################################
#
# Other values
#
######################################################################

# Reset down below.  See notes in ptsolvedocs.sh
MUMPS_BUILDS=${MUMPS_BUILDS:-"ser,par"}
MUMPS_DEPS=cmake
MUMPS_UMASK=002

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
  if bilderConfig mumps par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $MUMPS_PAR_OTHER_ARGS $CMAKE_LINLIB_SER_ARGS"; then
    bilderBuild mumps par
  fi
}

######################################################################
#
# Test mumps
#
######################################################################

testMumps() {
    echo " No testing for mumps"
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

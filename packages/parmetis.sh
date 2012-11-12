#!/bin/bash
#
# Version and build information for parmetis
#
# $Id: parmetis.sh 6364 2012-07-15 09:04:57Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################
PARMETIS_BLDRVERSION=${PARMETIS_BLDRVERSION:-"3.1.0"}


######################################################################
#
# Other values
#
######################################################################

if test -z "$PARMETIS_BUILDS"; then
  PARMETIS_BUILDS=par,parsh
fi

PARMETIS_DEPS=${PARMETIS_DEPS:-"cmake,openmpi"}
PARMETIS_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch parmetis builds.
#
######################################################################

buildParmetis() {
  if bilderUnpack parmetis; then
    if bilderConfig parmetis par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $PARMETIS_PAR_OTHER_ARGS $PARMETIS_PAR_ADDL_ARGS"; then
      bilderBuild parmetis par
    fi
    if bilderConfig parmetis parsh "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $PARMETIS_PAR_OTHER_ARGS $PARMETIS_PAR_ADDL_ARGS -DBUILD_SHARED_LIBS:BOOL=ON"; then
      bilderBuild parmetis parsh
    fi
  fi
}

######################################################################
#
# Test parmetis
#
######################################################################

testParmetis() {
  techo "Not testing parmetis."
}

######################################################################
#
# Install parmetis
#
######################################################################

installParmetis() {
  bilderInstall parmetis par
  bilderInstall parmetis parsh
}

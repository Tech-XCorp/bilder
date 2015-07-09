#!/bin/bash
#
# Version and build information for parmetis
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PARMETIS_BLDRVERSION=${PARMETIS_BLDRVERSION:-"4.0.3"}

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

if test -z "$PARMETIS_BUILDS"; then
  case `uname` in
    Linux) PARMETIS_BUILDS=par,parsh;;
    Darwin) PARMETIS_BUILDS=par;;
  esac
fi
PARMETIS_DEPS=${PARMETIS_DEPS:-"cmake,$MPI_BUILD"}
PARMETIS_UMASK=002

######################################################################
#
# Launch builds.
#
######################################################################

buildParmetis() {
  local PARMETIS_CMAKE_COMPFLAGS_PAR="$CMAKE_COMPFLAGS_PAR -I/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/malloc.h"
  if bilderUnpack parmetis; then
    if bilderConfig parmetis par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $PARMETIS_PAR_OTHER_ARGS"; then
      bilderBuild parmetis par
    fi
    if bilderConfig parmetis parsh "-DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $PARMETIS_PAR_OTHER_ARGS"; then
      bilderBuild parmetis parsh
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testParmetis() {
  techo "Not testing parmetis."
}

######################################################################
#
# Install
#
######################################################################

installParmetis() {
  bilderInstall parmetis par
  bilderInstall parmetis parsh
}


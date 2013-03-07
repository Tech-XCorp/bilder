#!/bin/bash
#
# Version and build information for superlu_dist
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################
SUPERLU_DIST_BLDRVERSION=${SUPERLU_DIST_BLDRVERSION:-"2.5"}


######################################################################
#
# Other values
#
######################################################################

if test -z "$SUPERLU_DIST_BUILDS"; then
  SUPERLU_DIST_BUILDS="par,parcomm"
  case `uname` in
    Linux) SUPERLU_DIST_BUILDS="${SUPERLU_DIST_BUILDS},parsh,parcommsh"
  esac
fi

# Not sure if we need the dependency to atlas, lapack and clapack_cmake
SUPERLU_DIST_DEPS=${SUPERLU_DIST_DEPS:-"cmake,openmpi,atlas,lapack,clapack_cmake"}
SUPERLU_DIST_UMASK=002

# Add parmetis if there are only standard builds and no commercial builds
if !(grep -q comm <<<$SUPERLU_DIST_BUILDS); then
  $SUPERLU_DIST_DEPS=$SUPERLU_DIST_DEPS,parmetis
fi


######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch superlu_dist builds.
#
######################################################################

buildSuperlu_Dist() {
  if bilderUnpack superlu_dist; then
    if bilderConfig -c superlu_dist par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PAR_OTHER_ARGS $SUPERLU_DIST_PAR_ADDL_ARGS"; then
      bilderBuild superlu_dist par "$SUPERLU_DIST_PAR_MAKE_ARGS"
    fi
    if bilderConfig superlu_dist parsh "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PAR_OTHER_ARGS $SUPERLU_DIST_PAR_ADDL_ARGS -DBUILD_SHARED_LIBS:BOOL=ON" ; then
      bilderBuild superlu_dist parsh "$SUPERLU_DIST_PAR_MAKE_ARGS"
    fi
    if bilderConfig -c superlu_dist parcomm "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PAR_OTHER_ARGS $SUPERLU_DIST_PAR_ADDL_ARGS"; then
      bilderBuild superlu_dist parcomm "$SUPERLU_DIST_PAR_MAKE_ARGS"
    fi
    if bilderConfig superlu_dist parcommsh "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST_PAR_OTHER_ARGS $SUPERLU_DIST_PAR_ADDL_ARGS -DBUILD_SHARED_LIBS:BOOL=ON" ; then
      bilderBuild superlu_dist parcommsh "$SUPERLU_DIST_PAR_MAKE_ARGS"
    fi

  fi
}

######################################################################
#
# Test superlu_dist
#
######################################################################

testSuperlu_Dist() {
  techo "Not testing superlu_dist."
}

######################################################################
#
# Install superlu_dist
#
######################################################################

installSuperlu_Dist() {
  for bld in parcommsh parcomm parsh par; do
    if bilderInstall -r superlu_dist $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/superlu_dist-$SUPERLU_DIST_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}

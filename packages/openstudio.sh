#!/bin/bash
#
# Version and build information for openstudio
#
# $Id: openstudio.sh 664 2013-06-17 21:15:06Z pletzer $
#
######################################################################

######################################################################
#
# Builds and deps
# Built from svn repo only
#
######################################################################

# OPENSTUDIO_DEPS=chombo,hdf5,metatau,petscrepo,muparser,txbase,pspline,netlib_lite,netcdf
OPENSTUDIO_DEPS=swig,dakota,doxygen,ruby

if test -z "$OPENSTUDIO_BUILDS"; then
  OPENSTUDIO_BUILDS=ser
fi

######################################################################
#
# Launch openstudio builds.
#
######################################################################

buildOpenstudio() {

  # Strip the compiler names to match the Chombo installed library names
  # OPENSTUDIO_SER_ARGS="-DENABLE_PARALLEL:BOOL=OFF -DUSE_EB:BOOL=ON -DCH_CXX:STRING='$CH_CXX' -DCH_FC:STRING='$CH_FC' -DCMAKE_Fortran_COMPILER='$FC' -DPETSC_FIND_VERSION:STRING=3.4 $CMAKE_COMPILERS_SER"
  # OPENSTUDIO_PAR_ARGS="-DENABLE_PARALLEL:BOOL=ON -DUSE_EB:BOOL=ON -DCH_CXX:STRING='$CH_MPICXX' -DCH_FC:STRING='$CH_FC' -DCMAKE_Fortran_COMPILER='$FC' -DPETSC_FIND_VERSION:STRING=3.4 $CMAKE_COMPILERS_PAR"

  OPENSTUDIO_SER_ARGS=" "
  OPENSTUDIO_PAR_ARGS=" "

  OPENSTUDIO_SER_ARGS="$OPENSTUDIO_SER_ARGS $CMAKE_COMPILERS_SER"
  OPENSTUDIO_PAR_ARGS="$OPENSTUDIO_PAR_ARGS $CMAKE_COMPILERS_PAR"

  #case `uname` in
  # CYGWIN*)
  #  if test -n $LINK_WITH_MKL; then
  #    OPENSTUDIO_SER_ARGS="$OPENSTUDIO_SER_ARGS -DLINK_WITH_MKL:BOOL=ON"
  #    OPENSTUDIO_PAR_ARGS="$OPENSTUDIO_PAR_ARGS -DLINK_WITH_MKL:BOOL=ON"
  #  fi
  #  ;;
  #esac

  # Get openstudio checkout
  getVersion openstudio

  # Configure and build serial and parallel
  if bilderPreconfig openstudio; then

    # Serial build
    if bilderConfig $USE_CMAKE_ARG openstudio ser "$OPENSTUDIO_SER_ARGS $CMAKE_SUPRA_SP_ARG"; then
       bilderBuild openstudio ser "$OPENSTUDIO_MAKEJ_ARGS"
    fi

  fi
}



######################################################################
#
# Install openstudio
#
######################################################################

installOpenstudio() {
  bilderInstall openstudio ser openstudio-ser
}

#!/bin/bash
#
# Version and build information for chombo
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

CHOMBO_BLDRVERSION=${CHOMBO_BLDRVERSION:-"21101"}

######################################################################
#
# Builds and deps
#
######################################################################

CHOMBO_DEPS=petsc34,hdf5,openmpi
if test -z "$CHOMBO_BUILDS"; then
  CHOMBO_BUILDS=par3d,par2d,par2ddbg,par3ddbg,ser3d
fi

# For testing
if [ $USER == 'swsides' ]; then
    CHOMBO_BUILDS=${CHOMBO_BUILDS},ser2d
fi

######################################################################
#
# Launch chombo builds.
#
######################################################################

buildChombo() {

  # Chombo common "configure arguments
  CHOMBO_SER_COMP="FC=$FC CXX=$CXX"
  CHOMBO_PAR_COMP="FC=$FC CXX=$MPICXX MPICXX=$MPICXX"
  techo -2 "CHOMBO_SER_COMP = $CHOMBO_SER_COMP"
  techo -2 "CHOMBO_PAR_COMP = $CHOMBO_PAR_COMP"

  HDF5_SER='HDFINCFLAGS="-DH5_USE_16_API -I'$HDF5_SER_DIR'/include" HDFLIBFLAGS="-L'$HDF5_SER_DIR'/lib -lhdf5 -lz"'
  HDF5_PAR='HDFMPILIBFLAGS="-L'$HDF5_PAR_DIR'/lib -lhdf5 -lz" HDFMPIINCFLAGS="-DH5_USE_16_API -I'$HDF5_PAR_DIR'/include"'

  # turning PETSC=TRUE off until we solve the ar issue on Mac OS X
  CHOMBO_OTHER_ARGS="USE_EB=TRUE USE_64=TRUE PROFILE=FALSE USE_MT=FALSE USE_COMPLEX=FALSE PRECISION=DOUBLE USE_HDF=TRUE USE_FFTW=FALSE" # PETSC=TRUE"

  # Specifc chombo args
  CHOMBO_SER_ARGS="$CHOMBO_SER_COMP $HDF5_SER $PETSC_SER"
  CHOMBO_PAR_ARGS="$CHOMBO_PAR_COMP $HDF5_SER $HDF5_PAR $PETSC_PAR"
  techo -2 "CHOMBO_SER_ARGS = $CHOMBO_SER_ARGS"
  techo -2 "CHOMBO_PAR_ARGS = $CHOMBO_PAR_ARGS"

  if test -z $LINK_WITH_MKL; then
    LINK_WITH_MKL_ARGS="-DLINK_WITH_MKL:BOOL=OFF"
  else
    LINK_WITH_MKL_ARGS="-DLINK_WITH_MKL:BOOL=ON"
  fi
  
  case `uname` in
    CYGWIN*)
      # on windows, we don't want the full path, which may contain spaces
      FC=`basename "$FC"`
      CC=`basename "$CC"`
      CXX=`basename "$CXX"`
      MPIFC=`basename "$MPIFC"`
      MPICC=`basename "$MPICC"`
      MPICXX=`basename "$MPICXX"`
      ;;
  esac
  
  if bilderUnpack chombo; then

     # ser2d
     if bilderConfig -c chombo ser2d "-DENABLE_PARALLEL:BOOL=OFF -DSPACEDIM:INT=2 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON $LINK_WITH_MKL_ARGS -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DCMAKE_C_COMPILER:FILEPATH=$CC -DCMAKE_CXX_COMPILER:FILEPATH=$CXX -DPETSC_FIND_VERSION:STRING=3.4 -DSUPERLU_FIND_VERSION:STRING=-$SUPERLU_BLDRVERSION-ser $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo ser2d "$CHOMBO_MAKEJ_ARGS"
     fi 

     # ser3d
     if bilderConfig -c chombo ser3d "-DENABLE_PARALLEL:BOOL=OFF -DSPACEDIM:INT=3 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON $LINK_WITH_MKL_ARGS -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DCMAKE_C_COMPILER:FILEPATH=$CC -DCMAKE_CXX_COMPILER:FILEPATH=$CXX -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.4 -DSUPERLU_FIND_VERSION:STRING=-$SUPERLU_BLDRVERSION-ser $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo ser3d "$CHOMBO_MAKEJ_ARGS"
     fi 

     # par2d
     if bilderConfig -c chombo par2d "-DENABLE_PARALLEL:BOOL=ON -DSPACEDIM:INT=2 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON $LINK_WITH_MKL_ARGS -DCMAKE_Fortran_COMPILER:FILEPATH=$MPIFC -DCMAKE_C_COMPILER:FILEPATH=$MPICC -DCMAKE_CXX_COMPILER:FILEPATH=$MPICXX -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.4 -DSUPERLU_FIND_VERSION:STRING=-$SUPERLU_DIST_BLDRVERSION-par $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo par2d "$CHOMBO_MAKEJ_ARGS"
     fi 

     # par3d
     if bilderConfig -c chombo par3d "-DENABLE_PARALLEL:BOOL=ON -DSPACEDIM:INT=3 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON $LINK_WITH_MKL_ARGS -DCMAKE_Fortran_COMPILER:FILEPATH=$MPIFC -DCMAKE_C_COMPILER:FILEPATH=$MPICC -DCMAKE_CXX_COMPILER:FILEPATH=$MPICXX -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.4 -DSUPERLU_FIND_VERSION:STRING=-$SUPERLU_DIST_BLDRVERSION-par $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo par3d "$CHOMBO_MAKEJ_ARGS"
     fi 

  fi

}

######################################################################
#
# Install chombo
#
######################################################################

installChombo() {

  bilderInstall chombo ser2d chombo-ser2d
  bilderInstall chombo ser3d chombo-ser3d
  bilderInstall chombo par2d chombo-par2d
  bilderInstall chombo par3d chombo-par3d

}


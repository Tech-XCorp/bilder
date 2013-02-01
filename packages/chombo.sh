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

CHOMBO_BLDRVERSION=${CHOMBO_BLDRVERSION:-"2013-01-24"}

######################################################################
#
# Builds and deps
#
######################################################################

CHOMBO_DEPS=petsc33,hdf5,openmpi
if test -z "$CHOMBO_BUILDS"; then
  CHOMBO_BUILDS=par3d,par2d,par2ddbg,par3ddbg,ser3d
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

  if bilderUnpack chombo; then

     # ser2d
     if bilderConfig -c chombo ser2d "-DENABLE_PARALLEL:BOOL=OFF -DSPACEDIM:INT=2 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo ser2d "$CHOMBO_MAKEJ_ARGS"
     fi 

     # ser3d
     if bilderConfig -c chombo ser3d "-DENABLE_PARALLEL:BOOL=OFF -DSPACEDIM:INT=3 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo ser3d "$CHOMBO_MAKEJ_ARGS"
     fi 

     # par2d
     if bilderConfig -c chombo par2d "-DENABLE_PARALLEL:BOOL=ON -DSPACEDIM:INT=2 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo par2d "$CHOMBO_MAKEJ_ARGS"
     fi 

     # par3d
     if bilderConfig -c chombo par3d "-DENABLE_PARALLEL:BOOL=ON -DSPACEDIM:INT=3 -DCMAKE_BUILD_TYPE:STRING=Release -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo par3d "$CHOMBO_MAKEJ_ARGS"
     fi 

     if [ $USER != 'swsides' ]; then

     # ser2ddbg
     if bilderConfig -c chombo ser2ddbg "-DENABLE_PARALLEL:BOOL=OFF -DSPACEDIM:INT=2 -DCMAKE_BUILD_TYPE:STRING=Debug -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo ser2ddbg "$CHOMBO_MAKEJ_ARGS"
     fi 

     # ser3ddbg
     if bilderConfig -c chombo ser3ddbg "-DENABLE_PARALLEL:BOOL=OFF -DSPACEDIM:INT=3 -DCMAKE_BUILD_TYPE:STRING=Debug -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo ser3ddbg "$CHOMBO_MAKEJ_ARGS"
     fi 

     # par2ddbg
     if bilderConfig -c chombo par2ddbg "-DENABLE_PARALLEL:BOOL=ON -DSPACEDIM:INT=2 -DCMAKE_BUILD_TYPE:STRING=Debug -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo par2ddbg "$CHOMBO_MAKEJ_ARGS"
     fi 

     # par3ddbg
     if bilderConfig -c chombo par3ddbg "-DENABLE_PARALLEL:BOOL=ON -DSPACEDIM:INT=3 -DCMAKE_BUILD_TYPE:STRING=Debug -DUSE_EB:BOOL=ON -DCMAKE_Fortran_COMPILER:FILEPATH=$FC -DPETSC:BOOL=ON -DPETSC_FIND_VERSION:STRING=3.3 $CMAKE_SUPRA_SP_ARG"; then
        bilderBuild chombo par3ddbg "$CHOMBO_MAKEJ_ARGS"
     fi 

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
  bilderInstall chombo ser2ddbg chombo-ser2ddbg
  bilderInstall chombo ser3ddbg chombo-ser3ddbg
  bilderInstall chombo par2ddbg chombo-par2ddbg
  bilderInstall chombo par3ddbg chombo-par3ddbg

}


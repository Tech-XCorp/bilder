#!/bin/bash
#
# Build information for puffin
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in puffin_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/puffin_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPuffinNonTriggerVars() {
  PUFFIN_UMASK=002
}
setPuffinNonTriggerVars

######################################################################
#
# Launch puffin builds.
#
######################################################################

buildPuffin() {
# Unpack
  if ! bilderUnpack puffin; then
    return
  fi
  local PUFFIN_SER_ADDL_ARGS=
  local PUFFIN_SERSH_ADDL_ARGS=
  local PUFFIN_PAR_ADDL_ARGS=
  local PUFFIN_PARSH_ADDL_ARGS=
  case `uname` in
    Darwin)
# Shared libs to know their installation names so that builds of
# dependents link to this for installation to work without DYLD_LIBRARY_PATH
      PUFFIN_DARWIN_ADDL_ARGS=" -DDEBUG_CMAKE:BOOL=TRUE "
      PUFFIN_SERSH_ADDL_ARGS="$PUFFIN_DARWIN_ADDL_ARGS " 
      PUFFIN_SER_ADDL_ARGS="$PUFFIN_DARWIN_ADDL_ARGS  "
      PUFFIN_PARSH_ADDL_ARGS="$PUFFIN_DARWIN_ADDL_ARGS " 
      PUFFIN_PAR_ADDL_ARGS="$PUFFIN_DARWIN_ADDL_ARGS " 
      ;;
    Linux)
      PUFFIN_LINUX_ADDL_ARGS=" -DDEBUG_CMAKE:BOOL=TRUE "
#      NO GUARDS - ASSUMED ALWAYS PARALLEL
#      PUFFIN_SERSH_ADDL_ARGS="$PUFFIN_LINUX_ADDL_ARGS "
#      PUFFIN_SER_ADDL_ARGS="$PUFFIN_LINUX_ADDL_ARGS -DFftw_ROOT_DIR=$FFTW_SER_DIR -DHdf5_ROOT_DIR=$HDF5_SER_DIR"
      PUFFIN_PAR_ADDL_ARGS="$PUFFIN_LINUX_ADDL_ARGS  -DFftw_ROOT_DIR=$FFTW_PAR_DIR -DHdf5_ROOT_DIR=$HDF5_PAR_DIR"
#      PUFFIN_PARMIC_ADDL_ARGS="$PUFFIN_LINUX_ADDL_ARGS  -DFftw_ROOT_DIR=$FFTW_PAR_DIR -DHdf5_ROOT_DIR=$HDF5_PAR_DIR"
      PUFFIN_PARSH_ADDL_ARGS="$PUFFIN_LINUX_ADDL_ARGS"
#     PUFFIN_SERSH_ADDL_ARGS="$PUFFIN_SERSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH"
      ;;
  esac
  
#  if (INTEL); then
   
#  -DCMAKE_INSTALL_PREFIX:PATH='/gpfs/stfc/local/HCP084/bwm06/shared/volatile-intel2015-openmpi/puffin-29.0Beta5-ser/' \
#  -DNCURSES_INCLUDE_DIR:PATH='/gpfs/stfc/local/HCP084/bwm06/shared/contrib-intel2015-openmpi/ncurses-sersh/include' \
#  -DDEBUG_CMAKE:BOOL=TRUE \
#  -DCMAKE_BUILD_TYPE:STRING="Release" \
##  -DENABLE_GPU:BOOL=FALSE \
#  -DENABLE_VALIDATE_GPU:BOOL=FALSE \
#  -DENABLE_PARALLEL:BOOL=FALSE \
#  -DBUILD_UTILS:BOOL=TRUE \
#  -DSUPRA_SEARCH_PATH:PATH='/gpfs/stfc/local/HCP084/bwm06/shared/contrib-intel2015-openmpi' \
#  /gpfs/stfc/local/HCP084/bwm06/shared/GPUpuffin


# Build
  techo "Looking for FFTW"
  techo $LD_LIBRARY_PATH
  if bilderConfig -c puffin sersh "-DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $PUFFIN_SERSH_ADDL_ARGS $PUFFIN_SERSH_OTHER_ARGS"; then
    bilderBuild puffin sersh "$PUFFIN_MAKEJ_ARGS"
  fi
  if bilderConfig -c puffin parsh "-DENABLE_PARALLEL:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $PUFFIN_PARSH_ADDL_ARGS $PUFFIN_PARSH_OTHER_ARGS"; then
    bilderBuild puffin parsh "$PUFFIN_MAKEJ_ARGS"
  fi
  if bilderConfig -c puffin ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $PUFFIN_SER_ADDL_ARGS $PUFFIN_SER_OTHER_ARGS"; then
    bilderBuild puffin ser "$PUFFIN_MAKEJ_ARGS"
  fi
  if bilderConfig -c puffin par "-DENABLE_PARALLEL:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $PUFFIN_PAR_ADDL_ARGS $PUFFIN_PAR_OTHER_ARGS"; then
    bilderBuild puffin par "$PUFFIN_MAKEJ_ARGS"
  fi
}

######################################################################
#
# Test puffin
#
######################################################################

testPuffin() {
  techo "Not testing puffin."
}

######################################################################
#
# Install puffin
#
######################################################################

installPuffin() {
  bilderInstall puffin sersh
  bilderInstall puffin ser
  bilderInstall puffin parsh
  bilderInstall puffin par
}


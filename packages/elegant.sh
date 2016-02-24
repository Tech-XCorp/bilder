#!/bin/bash
#
# Build information for elegant
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in elegant_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/elegant_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setElegantNonTriggerVars() {
  ELEGANT_UMASK=002
}
setElegantNonTriggerVars

######################################################################
#
# Launch elegant builds.
#
######################################################################

buildElegant() {
# Unpack
  if ! bilderUnpack elegant; then
    return
  fi
  local ELEGANT_SER_ADDL_ARGS=
  local ELEGANT_SERSH_ADDL_ARGS=
  local ELEGANT_PAR_ADDL_ARGS=
  local ELEGANT_PARSH_ADDL_ARGS=
  case `uname` in
    Darwin)
# Shared libs to know their installation names so that builds of
# dependents link to this for installation to work without DYLD_LIBRARY_PATH
#      ELEGANT_DARWIN_ADDL_ARGS=" -DDEBUG_CMAKE:BOOL=TRUE  -DCMAKE_BUILD_TYPE:STRING='Release' -DENABLE_VALIDATE_GPU:BOOL=FALSE -DBUILD_UTILS:BOOL=TRUE"
      ELEGANT_DARWIN_ADDL_ARGS=" -DDEBUG_CMAKE:BOOL=TRUE  -DENABLE_VALIDATE_GPU:BOOL=FALSE -DBUILD_UTILS:BOOL=TRUE"
      ELEGANT_SERSH_ADDL_ARGS="$ELEGANT_DARWIN_ADDL_ARG  -DENABLE_GPU:BOOL=FALSE " 
      ELEGANT_SER_ADDL_ARGS="$ELEGANT_DARWIN_ADDL_ARGS  -DENABLE_GPU:BOOL=FALSE "
      ELEGANT_SERGPU_ADDL_ARGS="$ELEGANT_DARWIN_ADDL_ARGS -DENABLE_GPU:BOOL=TRUE " 
      ELEGANT_PARSH_ADDL_ARGS="$ELEGANT_DARWIN_ADDL_ARGS -DENABLE_GPU:BOOL=FALSE " 
      ELEGANT_PAR_ADDL_ARGS="$ELEGANT_DARWIN_ADDL_ARGS -DENABLE_GPU:BOOL=FALSE " 
      ELEGANT_PARGPU_ADDL_ARGS="$ELEGANT_DARWIN_ADDL_ARGS -DENABLE_GPU:BOOL=TRUE " 
      ;;
    Linux)
      ELEGANT_LINUX_ADDL_ARGS=" -DDEBUG_CMAKE:BOOL=TRUE  -DENABLE_VALIDATE_GPU:BOOL=FALSE -DBUILD_UTILS:BOOL=TRUE"
      ELEGANT_SERSH_ADDL_ARGS="$ELEGANT_LINUX_ADDL_ARGS  -DENABLE_GPU:BOOL=FALSE "
      ELEGANT_SER_ADDL_ARGS="$ELEGANT_LINUX_ADDL_ARGS -DENABLE_GPU:BOOL=FALSE "
      ELEGANT_SERGPU_ADDL_ARGS="$ELEGANT_LINUX_ADDL_ARGS -DENABLE_GPU:BOOL=TRUE "
      ELEGANT_PAR_ADDL_ARGS="$ELEGANT_LINUX_ADDL_ARGS -DENABLE_GPU:BOOL=FALSE "
      ELEGANT_PARSH_ADDL_ARGS="$ELEGANT_LINUX_ADDL_ARGS -DENABLE_GPU:BOOL=FALSE "
      ELEGANT_PARGPU_ADDL_ARGS="$ELEGANT_LINUX_ADDL_ARGS -DENABLE_GPU:BOOL=TRUE "
#     ELEGANT_SERSH_ADDL_ARGS="$ELEGANT_SERSH_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$LD_LIBRARY_PATH"
      ;;
  esac
  
#  if (INTEL); then
   
#  -DCMAKE_INSTALL_PREFIX:PATH='/gpfs/stfc/local/HCP084/bwm06/shared/volatile-intel2015-openmpi/elegant-29.0Beta5-ser/' \
#  -DNCURSES_INCLUDE_DIR:PATH='/gpfs/stfc/local/HCP084/bwm06/shared/contrib-intel2015-openmpi/ncurses-sersh/include' \
#  -DDEBUG_CMAKE:BOOL=TRUE \
#  -DCMAKE_BUILD_TYPE:STRING="Release" \
##  -DENABLE_GPU:BOOL=FALSE \
#  -DENABLE_VALIDATE_GPU:BOOL=FALSE \
#  -DENABLE_PARALLEL:BOOL=FALSE \
#  -DBUILD_UTILS:BOOL=TRUE \
#  -DSUPRA_SEARCH_PATH:PATH='/gpfs/stfc/local/HCP084/bwm06/shared/contrib-intel2015-openmpi' \
#  /gpfs/stfc/local/HCP084/bwm06/shared/GPUelegant


# Build
  if bilderConfig -c elegant sersh "-DBUILD_SHARED_LIBS:BOOL=ON  $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $ELEGANT_SERSH_ADDL_ARGS $ELEGANT_SERSH_OTHER_ARGS"; then
    bilderBuild elegant sersh "$ELEGANT_MAKEJ_ARGS"
  fi
  if bilderConfig -c elegant parsh "-DENABLE_PARALLEL:BOOL=ON -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $ELEGANT_PARSH_ADDL_ARGS $ELEGANT_PARSH_OTHER_ARGS"; then
    bilderBuild elegant parsh "$ELEGANT_MAKEJ_ARGS"
  fi
  if bilderConfig -c elegant ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $ELEGANT_SER_ADDL_ARGS $ELEGANT_SER_OTHER_ARGS"; then
    bilderBuild elegant ser "$ELEGANT_MAKEJ_ARGS"
  fi
  if bilderConfig -c elegant par "-DENABLE_PARALLEL:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $ELEGANT_PAR_ADDL_ARGS $ELEGANT_PAR_OTHER_ARGS"; then
    bilderBuild elegant par "$ELEGANT_MAKEJ_ARGS"
  fi
  if bilderConfig -c elegant sergpu "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $ELEGANT_SERGPU_ADDL_ARGS $ELEGANT_SERGPU_OTHER_ARGS"; then
    bilderBuild elegant sergpu "$ELEGANT_MAKEJ_ARGS"
  fi
  if bilderConfig -c elegant pargpu "-DENABLE_PARALLEL:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $ELEGANT_PARGPU_ADDL_ARGS $ELEGANT_PARGPU_OTHER_ARGS"; then
    bilderBuild elegant pargpu "$ELEGANT_MAKEJ_ARGS"
  fi
}

######################################################################
#
# Test elegant
#
######################################################################

testElegant() {
  techo "Not testing elegant."
}

######################################################################
#
# Install elegant
#
######################################################################

installElegant() {
  bilderInstall elegant sersh
  bilderInstall elegant ser
  bilderInstall elegant parsh
  bilderInstall elegant par
  bilderInstall elegant sergpu
  bilderInstall elegant pargpu
}


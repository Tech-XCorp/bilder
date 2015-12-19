#!/bin/bash
#
# Build information for cgm
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
# Putting the version information into oce_aux.sh eliminates the
# rebuild when one changes that file.  Of course, if the actual version
# changes, or this file changes, there will be a rebuild.  But with
# this one can change the experimental version without causing a rebuild
# in a non-experimental Bilder run.  One can also change any auxiliary
# functions without sparking a build.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/cgm_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setCgmNonTriggerVars() {
  CGM_UMASK=002
}
setCgmNonTriggerVars

######################################################################
#
# Launch cgm builds.
#
######################################################################

#
# Build CGM
#
buildCgm() {

# Whether using cmake
# As of 20151220, autotools is still necessary to build cgm without cubit.
  # if $BUILD_EXPERIMENTAL; then
    # CGM_USE_CMAKE=${CGM_USE_CMAKE:-"true"}
  # fi
  CGM_USE_CMAKE=${CGM_USE_CMAKE:-"false"}
  if [[ `uname` =~ CYGWIN ]]; then
    CGM_USE_CMAKE=true
  fi
  local cgmcmakearg=
  local sharedarg=
  if $CGM_USE_CMAKE; then
    cgmcmakearg=-c
    sharedarg="-DBUILD_SHARED_LIBS='ON'"
  else
    sharedarg="--enable-shared"
  fi

# Get cgm from repo, determine whether to build
  updateRepo cgm
  getVersion cgm
  if ! bilderPreconfig $cgmcmakearg cgm; then
    return 1
  fi

# Configure and build args
  local CGM_ADDL_ARGS=
  if $CGM_USE_CMAKE; then
    CGM_ADDL_ARGS="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC -DCGM_OCC='ON' $OCE_PYCSH_CMAKE_DIR_ARG"
    if [[ `uname` =~ CYGWIN ]]; then
      CGM_ADDL_ARGS="-DBUILD_WITH_SHARED_RUNTIME:BOOL=TRUE $CGM_ADDL_ARGS"
    fi
  else
    CGM_ADDL_ARGS="$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC --with-occ='$OCE_PYCSH_DIR'"
  fi

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$CGM_MAKEJ_ARGS"
  fi

#
# Configure and build
#

# PYTHON_STATIC_BUILD for composers
  local otherargsvar=`genbashvar CGM_${FORPYTHON_STATIC_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`
  if bilderConfig $cgmcmakearg cgm $FORPYTHON_STATIC_BUILD "$CGM_ADDL_ARGS $otherargsval" "" "$CGM_ENV"; then
    bilderBuild $makerargs cgm $FORPYTHON_STATIC_BUILD "$makejargs" "$CGM_ENV"
  fi

# PYTHON_SHARED_BUILD for dagsolid
  local otherargsvar=`genbashvar CGM_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargsval=`deref ${otherargsvar}`
  if bilderConfig $cgmcmakearg cgm $FORPYTHON_SHARED_BUILD "$sharedarg $CGM_ADDL_ARGS $otherargsval" "" "$CGM_ENV"; then
    bilderBuild $makerargs cgm $FORPYTHON_SHARED_BUILD "$makejargs" "$CGM_ENV"
  fi

}

######################################################################
#
# Test cgm
#
######################################################################

testCgm() {
  techo "Not testing cgm."
}

######################################################################
#
# Install cgm
#
######################################################################

installCgm() {
  bilderInstallAll cgm
}


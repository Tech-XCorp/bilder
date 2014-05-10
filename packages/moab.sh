#!/bin/bash
#
# Version and build information for moab
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

setMoabVersion() {
  MOAB_REPO_URL=https://bitbucket.org/cadg4/moab.git
  MOAB_UPSTREAM_URL=https://bitbucket.org/fathomteam/moab.git
  MOAB_REPO_TAG_STD=master
  MOAB_REPO_TAG_EXP=master
}
setMoabVersion

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setMoabGlobalVars() {
  MOAB_BUILD=$FORPYTHON_BUILD
  MOAB_BUILDS=${MOAB_BUILDS:-"$FORPYTHON_BUILD"}
  MOAB_DEPS=cgm,netcdf
  MOAB_UMASK=002
}
setMoabGlobalVars

######################################################################
#
# Launch moab builds.
#
######################################################################

buildMoab() {

# Get moab from repo and remove any detritus
  updateRepo moab
  MOAB_USE_CMAKE=${MOAB_USE_CMAKE:-"false"}
  if [[ `uname` =~ CYGWIN ]]; then
    MOAB_USE_CMAKE=true
  fi
  local moabcmakearg=
  if $MOAB_USE_CMAKE; then
    moabcmakearg=-c
  fi

# Preconfig or unpack
  if test -d $PROJECT_DIR/moab; then
    getVersion moab
    if ! bilderPreconfig $moabcmakearg moab; then
      return 1
    fi
  else
    if ! bilderUnpack moab; then
      return 1
    fi
  fi

# Set other args, env
  local MOAB_ADDL_ARGS=
  if $MOAB_USE_CMAKE; then
    MOAB_ADDL_ARGS="$OCE_CC4PY_CMAKE_DIR_ARG"
  else
    MOAB_ADDL_ARGS="--enable-shared --with-hdf5='$HDF5_CC4PY_DIR' --with-netcdf='$NETCDF_CC4PY_DIR' --with-vtk= --with-cgm="
  fi
if false; then
  local netcdfrootdir=$CONTRIB_DIR/netcdf-${NETCDF_BLDRVERSION}-$FORPYTHON_BUILD
  if test -d "$netcdfrootdir"; then
    if [[ `uname` =~ CYGWIN ]]; then
      netcdfrootdir=`cygpath -m "$netcdfrootdir"`
    fi
    if $MOAB_USE_CMAKE; then
      MOAB_ADDL_ARGS="$MOAB_ADDL_ARGS -DNetCDF_PREFIX:PATH=$netcdfrootdir -DMOAB_USE_NETCDF:BOOL=ON -DNETCDF_DIR:PATH='$NETCDF_CC4PY_CMAKE_DIR'"
    else
      :
    fi
  fi
fi

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$MOAB_MAKEJ_ARGS"
  fi

# Configure and build
  local otherargs=`deref MOAB_${MOAB_BUILD}_OTHER_ARGS`
  local MOAB_CONFIG_ARGS=
  if $MOAB_USE_CMAKE; then
    MOAB_CONFIG_ARGS="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $MOAB_ADDL_ARGS $otherargs"
  else
    :
  fi
  if bilderConfig $makerargs $moabcmakearg moab $MOAB_BUILD "$MOAB_CONFIG_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab $MOAB_BUILD "$makejargs" "$MOAB_ENV"
  fi

}

######################################################################
#
# Test moab
#
######################################################################

testMoab() {
  techo "Not testing moab."
}

######################################################################
#
# Install moab
#
######################################################################

installMoab() {
  bilderInstallAll moab
}


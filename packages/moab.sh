#!/bin/bash
#
# Build information for moab
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
# Putting the version information into moab_aux.sh eliminates the
# rebuild when one changes that file.  Of course, if the actual version
# changes, or this file changes, there will be a rebuild.  But with
# this one can change the experimental version without causing a rebuild
# in a non-experimental Bilder run.  One can also change any auxiliary
# functions without sparking a build.
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/moab_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMoabNonTriggerVars() {
  MOAB_UMASK=002
}
setMoabNonTriggerVars

######################################################################
#
# Builds, deps, auxdata, paths, builds of other packages
#
######################################################################

#if test -z "$MOAB_DEPS"; then
#  MOAB_DEPS=$MPI_BUILD,zoltan,trilinos
#  MOAB_DEPS=${MOAB_DEPS:-"$MPI_BUILD,zoltan,trilinos"}
#fi
#if test -z "$TRILINOS_DESIRED_BUILDS"; then
#  TRILINOS_BUILDS=sercommio,parcommio
#  echo TRILINOS_BUILDS = $TRILINOS_BUILDS
#fi


######################################################################
#
# Launch moab builds.
#
######################################################################

buildMoab() {

# Get moab from repo, determine whether to build
  updateRepo moab
  getVersion moab
  if ! bilderPreconfig $moabcmakearg moab; then
    return 1
  fi

# Whether using cmake
  MOAB_USE_CMAKE=${MOAB_USE_CMAKE:-"false"}
  if [[ `uname` =~ CYGWIN ]]; then
    MOAB_USE_CMAKE=true
  fi
  local moabcmakearg=
  if $MOAB_USE_CMAKE; then
    moabcmakearg=-c
  fi

# Set other args, env
  local MOAB_ADDL_ARGS=
  local MOAB_PAR_ADDL_ARGS=
  if $MOAB_USE_CMAKE; then
    MOAB_ADDL_ARGS="$OCE_PYCSH_CMAKE_DIR_ARG"
  else
    # MOAB_ADDL_ARGS="--enable-shared --with-hdf5='$HDF5_PYCSH_DIR' --with-netcdf='$NETCDF_PYCSH_DIR' --with-vtk='$VTK_PYCSH_DIR' --with-cgm='$CGM_PYCSH_DIR'"
# moab cannot use recent vtk
# With cgm:
# checking for /volatile/cgm-master.r1081-sersh/cgm.make... no
# configure: error: /volatile/cgm-master.r1081-sersh : not a configured CGM
    MOAB_ADDL_ARGS="--enable-shared --without-vtk --with-hdf5='$HDF5_PYCSH_DIR' --with-netcdf='$NETCDF_PYCSH_DIR'"
    case `uname` in
      Linux)
        local nclibsubdir=lib
        if test -d "$NETCDF_PYCSH_DIR/lib64"; then
          nclibsubdir=lib64
        fi
        MOAB_ADDL_ARGS="$MOAB_ADDL_ARGS LDFLAGS=-Wl,-rpath,'$HDF5_PYCSH_DIR/lib':'$NETCDF_PYCSH_DIR/$nclibsubdir'"
        ;;
    esac
  fi
  local MOAB_ENV=

# add additional parallel args
  MOAB_PAR_ADDL_ARGS="--without-vtk --enable-shared --with-hdf5='$HDF5_PAR_DIR' --with-netcdf='$NETCDF_PYCSH_DIR' --with-mpi='$CONTRIB_DIR/mpi' --with-zoltan='$TRILINOS_INSTALL_DIRS/trilinos-parcomm' --enable-mbzoltan"


# Configure and build args
  local otherargsvar=`genbashvar MOAB_${MOAB_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  local MOAB_CONFIG_ARGS=
  local MOAB_PAR_CONFIG_ARGS=
  if $MOAB_USE_CMAKE; then
    MOAB_CONFIG_ARGS="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC $MOAB_ADDL_ARGS $otherargs"
    MOAB_PAR_CONFIG_ARGS="$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $MOAB_PAR_ADDL_ARGS $otherargs"
  else
    MOAB_CONFIG_ARGS="$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $MOAB_ADDL_ARGS $otherargs"
    MOAB_PAR_CONFIG_ARGS="$CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $MOAB_PAR_ADDL_ARGS $otherargs"
  fi

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$MOAB_MAKEJ_ARGS"
  fi

# Configure and build serial
  if bilderConfig $makerargs $moabcmakearg moab $MOAB_BUILD "$MOAB_CONFIG_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab $MOAB_BUILD "$makejargs" "$MOAB_ENV"
  fi

# Configure and build parallel
  if bilderConfig $makerargs $moabcmakearg moab par "$MOAB_PAR_CONFIG_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab par "$makejargs" "$MOAB_ENV"
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


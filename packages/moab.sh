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
# Launch moab builds.
#
######################################################################

buildMoab() {

# Whether using cmake
  local moabcmakearg=
  local enable_shared=
  if $MOAB_USE_CMAKE; then
    techo "Building MOAB with cmake."
    moabcmakearg=-c
  else
    techo "Building MOAB with autotools."
  fi

# Get moab from repo, determine whether to build
  updateRepo moab
  getVersion moab
  if ! bilderPreconfig $moabcmakearg moab; then
    return 1
  fi

#
# Basic configure and build args
#
# ser BUILD needed by ulixes
  local MOAB_SER_CONFIG_ARGS=
# FORPYTHON_STATIC_BUILD needed by composers
  local MOAB_PYCST_CONFIG_ARGS=
# FORPYTHON_SHARED_BUILD needed by dagmc
  local MOAB_PYCSH_CONFIG_ARGS=
# par BUILD needed by ulixes
  local MOAB_PAR_CONFIG_ARGS=
# zoltan arguments needed for ulixes-par
  local MOAB_ZOLTAN_ARGS=
  if $MOAB_USE_CMAKE; then
    MOAB_SER_CONFIG_ARGS="-DBUILD_SHARED_LIBS=FALSE $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER"
    MOAB_SERSH_CONFIG_ARGS="-DBUILD_SHARED_LIBS=TRUE $CMAKE_COMPILERS_SERSH $CMAKE_COMPFLAGS_SERSH"
    MOAB_PYCST_CONFIG_ARGS="-DBUILD_SHARED_LIBS:BOOL=FALSE $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
    MOAB_PYCSH_CONFIG_ARGS="-DBUILD_SHARED_LIBS:BOOL=TRUE -DCMAKE_INSTALL_NAME_DIR='${BLDR_INSTALL_DIR}/moab-${MOAB_BLDRVERSION}-$FORPYTHON_SHARED_BUILD/lib' $CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
    if echo "$MOAB_BUILDS" | grep -q "par"; then
      MOAB_PAR_CONFIG_ARGS="-DBUILD_SHARED_LIBS=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR -DENABLE_PARALLEL:BOOL=TRUE"
      MOAB_PARSH_CONFIG_ARGS="-DBUILD_SHARED_LIBS=TRUE $CMAKE_COMPILERS_PARSH $CMAKE_COMPFLAGS_PARSH -DENABLE_PARALLEL:BOOL=TRUE"
# Find Zoltan build. Pick parcommio as the default as that includes hdf5/netcdf/exodusII API's.
      if [[ ${CMAKE_TRILINOSREPO_PARCOMMIO_DIR} != "" ]]; then
        MOAB_ZOLTAN_ARGS="-DENABLE_ZOLTAN:BOOL=TRUE -DZOLTAN_DIR=${CMAKE_TRILINOSREPO_PARCOMMIO_DIR}"
      elif [[ ${CMAKE_TRILINOSREPO_PARCOMM_DIR} != "" ]]; then
        MOAB_ZOLTAN_ARGS="-DENABLE_ZOLTAN:BOOL=TRUE -DZOLTAN_DIR=${CMAKE_TRILINOSREPO_PARCOMM_DIR}"
      elif [[ ${CMAKE_TRILINOSREPO_PARFULL_DIR} != "" ]]; then
        MOAB_ZOLTAN_ARGS="-DENABLE_ZOLTAN:BOOL=TRUE -DZOLTAN_DIR=${CMAKE_TRILINOSREPO_PARFULL_DIR}"
      else
      techo "moab.sh: par build requested, but none of trilinos-parcomm, trilinos-parcommio or trilinos-parfull found. Disabling Zoltan"
      fi
    fi
  else
    MOAB_SER_CONFIG_ARGS="--enable-static --disable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER"
    MOAB_PYCST_CONFIG_ARGS="--enable-static --disable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC"
    MOAB_PYCSH_CONFIG_ARGS="--disable-static --enable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC"
    MOAB_PAR_CONFIG_ARGS="--with-mpi='$CONTRIB_DIR/mpi' --enable-static --disable-shared $CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR"
  fi

#
# Additional build args
#
# FORPYTHON_STATIC_BUILD needed by composers
  if $MOAB_USE_CMAKE; then
    MOAB_GENCONFIG_ARGS="-DENABLE_IMESH:BOOL=TRUE -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SER_DIR"
    # MOAB_BUILD_SET = Full has CGM capabilities
    if echo "$MOAB_BUILD_SET" | grep -q "Full"; then
      MOAB_SER_CONFIG_ARGS="$MOAB_SER_CONFIG_ARGS -DENABLE_IMESH:BOOL=TRUE -DENABLE_IGEOM:BOOL=TRUE  -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SER_DIR -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_SER_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SER_DIR' -DENABLE_DAGMC:BOOL=ON -DENABLE_CGM:BOOL=ON -DCGM_CFG='$CMAKE_CGM_PYCSH_DIR/lib/cgm.make' $OCE_SER_CMAKE_DIR_ARG"
      MOAB_SERSH_CONFIG_ARGS="$MOAB_SERSH_CONFIG_ARGS -DENABLE_IMESH:BOOL=TRUE -DENABLE_IGEOM:BOOL=TRUE  -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SERSH_DIR -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_SERSH_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SERSH_DIR' -DENABLE_DAGMC:BOOL=ON -DENABLE_CGM:BOOL=ON -DCGM_CFG='$CMAKE_CGM_PYCSH_DIR/lib/cgm.make' $OCE_SERSH_CMAKE_DIR_ARG"
      MOAB_PYCST_CONFIG_ARGS="$MOAB_PYCST_CONFIG_ARGS -DENABLE_IMESH:BOOL=TRUE -DENABLE_IGEOM:BOOL=TRUE -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SER_DIR -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCST_DIR' -DENABLE_DAGMC:BOOL=ON -DENABLE_CGM:BOOL=ON -DCGM_CFG='$CMAKE_CGM_PYCSH_DIR/lib/cgm.make' $OCE_PYCSH_CMAKE_DIR_ARG"
      MOAB_PYCSH_CONFIG_ARGS="$MOAB_PYCSH_CONFIG_ARGS -DBUILD_SHARED_LIBS:BOOL=true -DENABLE_IMESH:BOOL=TRUE -DENABLE_IGEOM:BOOL=TRUE -DENABLE_BOOST=FALSE -DBOOST_ROOT=$BOOST_SER_DIR -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCSH_DIR' -DENABLE_DAGMC:BOOL=ON -DENABLE_CGM:BOOL=ON -DCGM_CFG='$CGM_PYCSH_DIR/lib/cgm.make' $OCE_PYCSH_CMAKE_DIR_ARG"
      MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS -DMPI_DIR:PATH='$CONTRIB_DIR/mpi' -DENABLE_IMESH:BOOL=TRUE -DENABLE_IGEOM:BOOL=TRUE -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SER_DIR -DENABLE_IMESH:BOOL=TRUE -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PAR_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SER_DIR' $MOAB_ZOLTAN_ARGS -DENABLE_DAGMC:BOOL=ON -DENABLE_CGM:BOOL=ON -DCGM_CFG='$CMAKE_CGM_PYCSH_DIR/lib/cgm.make' $OCE_SER_CMAKE_DIR_ARG"
      MOAB_PARSH_CONFIG_ARGS="$MOAB_PARSH_CONFIG_ARGS -DMPI_DIR:PATH='$CONTRIB_DIR/mpi' -DENABLE_IMESH:BOOL=TRUE -DENABLE_IGEOM:BOOL=TRUE -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SERSH_DIR -DENABLE_IMESH:BOOL=TRUE -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PARSH_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SERSH_DIR' $MOAB_ZOLTAN_ARGS -DENABLE_DAGMC:BOOL=ON -DENABLE_CGM:BOOL=ON -DCGM_CFG='$CMAKE_CGM_PYCSH_DIR/lib/cgm.make' $OCE_SERSH_CMAKE_DIR_ARG"
    # MOAB_BUILD_SET = Lite only has meshing capabilities
    elif echo "$MOAB_BUILD_SET" | grep -q "Lite"; then
      MOAB_SER_CONFIG_ARGS="$MOAB_SER_CONFIG_ARGS -DENABLE_IMESH:BOOL=TRUE -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SER_DIR -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_SER_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SER_DIR' -DENABLE_CGM:BOOL=OFF -DMOAB_BUILD_DAGMC:BOOL=OFF"
      MOAB_SERSH_CONFIG_ARGS="$MOAB_SERSH_CONFIG_ARGS -DENABLE_IMESH:BOOL=TRUE -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SERSH_DIR -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_SERSH_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SERSH_DIR' -DENABLE_CGM:BOOL=OFF -DMOAB_BUILD_DAGMC:BOOL=OFF"
      MOAB_PYCST_CONFIG_ARGS="$MOAB_PYCST_CONFIG_ARGS -DMOAB_USE_HDF:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCST_DIR'"
      MOAB_PYCSH_CONFIG_ARGS="$MOAB_PYCSH_CONFIG_ARGS -DMOAB_USE_HDF:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCSH_DIR'"
      MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS -DMPI_DIR:PATH='$CONTRIB_DIR/mpi' -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SER_DIR -DENABLE_IMESH:BOOL=TRUE -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PAR_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SER_DIR' -DPNETCDF_ROOT='$NETCDF_PAR_DIR' -DENABLE_DAGMC:BOOL=OFF -DENABLE_CGM:BOOL=OFF -DMOAB_BUILD_MBPART:BOOL=ON -DMOAB_BUILD_DAGMC:BOOL=OFF $MOAB_ZOLTAN_ARGS"
      MOAB_PARSH_CONFIG_ARGS="$MOAB_PARSH_CONFIG_ARGS -DMPI_DIR:PATH='$CONTRIB_DIR/mpi' -DENABLE_BOOST=TRUE -DBOOST_ROOT=$BOOST_SERSH_DIR -DENABLE_IMESH:BOOL=TRUE -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PARSH_DIR' -DENABLE_NETCDF:BOOL=TRUE -DNETCDF_ROOT='$NETCDF_SERSH_DIR' -DPNETCDF_ROOT='$NETCDF_PARSH_DIR' -DENABLE_DAGMC:BOOL=OFF -DENABLE_CGM:BOOL=OFF -DMOAB_BUILD_MBPART:BOOL=ON -DMOAB_BUILD_DAGMC:BOOL=OFF $MOAB_ZOLTAN_ARGS"
    # Default choice
    else
      MOAB_SER_CONFIG_ARGS="$MOAB_SER_CONFIG_ARGS -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_SER_DIR' -DENABLE_CGM:BOOL=OFF"
      MOAB_SERSH_CONFIG_ARGS="$MOAB_SERSH_CONFIG_ARGS -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_SERSH_DIR' -DENABLE_CGM:BOOL=OFF"
      MOAB_PYCST_CONFIG_ARGS="$MOAB_PYCST_CONFIG_ARGS -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCST_DIR' -DENABLE_CGM:BOOL=OFF"
      MOAB_PYCSH_CONFIG_ARGS="$MOAB_PYCSH_CONFIG_ARGS -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PYCSH_DIR' -DENABLE_CGM:BOOL=OFF"
      MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS -DMPI_DIR:PATH='$CONTRIB_DIR/mpi' -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PAR_DIR' -DENABLE_CGM:BOOL=OFF -DMOAB_BUILD_MBPART:BOOL=ON $MOAB_ZOLTAN_ARGS"
      MOAB_PARSH_CONFIG_ARGS="$MOAB_PARSH_CONFIG_ARGS -DMPI_DIR:PATH='$CONTRIB_DIR/mpi' -DENABLE_HDF5:BOOL=TRUE -DHDF5_DIR:PATH='$HDF5_PARSH_DIR' -DENABLE_CGM:BOOL=OFF -DMOAB_BUILD_MBPART:BOOL=ON $MOAB_ZOLTAN_ARGS"
    fi
  else
# Moab cannot use recent vtk
# Moab cannot use recent cgm
# checking for /volatile/cgm-master.r1081-sersh/cgm.make... no
# configure: error: /volatile/cgm-master.r1081-sersh : not a configured CGM
    MOAB_SER_CONFIG_ARGS="$MOAB_SER_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_SER_DIR' --with-netcdf='$NETCDF_SER_DIR'"
# Neither CTK nor DagMC, which used shared moab, needs netcdf
    MOAB_PYCST_CONFIG_ARGS="$MOAB_PYCST_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_PYCST_DIR'"
# Neither CTK nor DagMC, which used shared moab, needs netcdf
    MOAB_PYCSH_CONFIG_ARGS="$MOAB_PYCSH_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_PYCSH_DIR'"
# Build parallel with netcdf to get exodus reader
    MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS --enable-dagmc --without-vtk --with-hdf5='$HDF5_PAR_DIR' --with-netcdf='$NETCDF_PAR_DIR'"
    case `uname` in
      Linux)
        local nclibsubdir=lib
        if test -d "$NETCDF_PYCSH_DIR/lib64"; then
          nclibsubdir=lib64
        fi
        MOAB_PYCSH_CONFIG_ARGS="$MOAB_PYCSH_CONFIG_ARGS LDFLAGS=-Wl,-rpath,'$HDF5_PYCSH_DIR/lib':'$NETCDF_PYCSH_DIR/$nclibsubdir'"
        ;;
    esac
# Parallel moab needs partitioning
    MOAB_PAR_CONFIG_ARGS="$MOAB_PAR_CONFIG_ARGS"
  fi

#
# Moab configure and build environment
#
  local MOAB_ENV=

# When not all dependencies right on Windows, need nmake
  local makerargs=
  local makejargs=
  if [[ `uname` =~ CYGWIN ]]; then
    makerargs="-m nmake"
  else
    makejargs="$MOAB_MAKEJ_ARGS"
  fi

# Configure and build serial
  if bilderConfig $makerargs $moabcmakearg moab ser${MOAB_BUILD_SET} "$MOAB_SER_CONFIG_ARGS $MOAB_SER_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab ser${moabBuildSet} "$makejargs" "$MOAB_ENV"
  fi

# Configure and build parallel
  if bilderConfig $makerargs $moabcmakearg moab par${MOAB_BUILD_SET} "$MOAB_PAR_CONFIG_ARGS $MOAB_PAR_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab par${moabBuildSet} "$makejargs" "$MOAB_ENV"
  fi

  if bilderConfig $makerargs $moabcmakearg moab sersh${MOAB_BUILD_SET} "$MOAB_SERSH_CONFIG_ARGS $MOAB_SERSH_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab ser${moabBuildSet} "$makejargs" "$MOAB_ENV"
  fi

  if bilderConfig $makerargs $moabcmakearg moab parsh${MOAB_BUILD_SET} "$MOAB_PARSH_CONFIG_ARGS $MOAB_PARSH_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab parsh${moabBuildSet} "$makejargs" "$MOAB_ENV"
  fi

# Configure and build python serial.  This may not be needed.
# Cannot use FORPYTHON_STATIC_BUILD on unixish where it can resolve to ser,
  if bilderConfig $makerargs $moabcmakearg moab pycst${MOAB_BUILD_SET} "$MOAB_PYCST_CONFIG_ARGS $MOAB_PYCST_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab pycst${moabBuildSet} "$makejargs" "$MOAB_ENV"
  fi

# Python shared build for composers.  Build with cmake.
  local otherargsvar=`genbashvar MOAB_${FORPYTHON_SHARED_BUILD}`_OTHER_ARGS
  local otherargs=`deref ${otherargsvar}`
  if bilderConfig $makerargs $moabcmakearg moab pycsh${MOAB_BUILD_SET} "$MOAB_PYCSH_CONFIG_ARGS $MOAB_PYCSH_OTHER_ARGS" "" "$MOAB_ENV"; then
    bilderBuild $makerargs moab pycsh${moabBuildSet} "$makejargs" "$MOAB_ENV"
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
# sersh build of moab needs hdf5 library installed, but moab does
# not install it.
# JRC: Why?  Applications need to collect all libs.  Libraries need not.
# Test applications can have a library path modification script.
  # if ! [[ `uname` =~ CYGWIN ]]; then
    # cp $HDF5_PYCSH_DIR/lib/libhdf5.* $BLDR_INSTALL_DIR/moab-sersh/lib
  # fi
}


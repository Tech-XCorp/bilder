#!/bin/bash
#
# Version and build information for netcdf
#
# $Id: netcdf.sh 6109 2012-05-24 17:15:49Z kruger $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

NETCDF_BLDRVERSION=${NETCDF_BLDRVERSION:-"4.1.2"}

######################################################################
#
# Other values
#
######################################################################

if test -z "$NETCDF_BUILDS"; then
  case `uname`-$NETCDF_BLDRVERSION in
    CYGWIN*)
      ;;
    *-3.*)
      NETCDF_BUILDS=${NETCDF_BUILDS:-"ser"}
      addBenBuild netcdf
      ;;
    *-4.*)
      NETCDF_BUILDS=${NETCDF_BUILDS:-"ser,par,cc4py"}
     ;;
  esac
  if test $BUILD_OPTIONAL && ! echo $NETCDF_BUILDS | egrep -q "(^|,)cc4py($|,)"; then
    NETCDF_BUILDS=${NETCDF_BUILDS}",cc4py"
  fi
fi
NETCDF_DEPS=hdf5,curl

######################################################################
#
# Launch netcdf builds.
#
######################################################################

buildNetcdf() {

# Environment
  case `uname` in
    Linux)
      local NETCDF_LLP="$HDF5_PAR_DIR/lib:$LIBFORTRAN_DIR:$LD_LIBRARY_PATH"
      local NETCDF_ENV="LD_LIBRARY_PATH=$NETCDF_LLP LD_RUN_PATH=$NETCDF_LLP"
      local NETCDF_LDFLAGS="LDFLAGS='-Wl,-rpath,$NETCDF_LLP'"
      local NETCDF_PAR_LLP="$HDF5_PAR_DIR/lib:$LIBFORTRAN_DIR:$LD_LIBRARY_PATH"
      local NETCDF_PAR_ENV="LD_LIBRARY_PATH=$NETCDF_PAR_LLP LD_RUN_PATH=$NETCDF_PAR_LLP"
      local NETCDF_PAR_LDFLAGS="LDFLAGS='-Wl,-rpath,$NETCDF_PAR_LLP'"
      ;;
  esac

# Set fortran munging flag
  local N_SER_CFLAGS=
  local N_PAR_CFLAGS=
  case $FC in
    *xlf*)
      N_SER_CFLAGS="$CFLAGS -DIBMR2Fortran"
      N_PAR_CFLAGS="$MPI_CFLAGS -DIBMR2Fortran"
      ;;
    *)  # For gfortran, pgi, path
      N_SER_CFLAGS="$CFLAGS -DpgiFortran"
      N_PAR_CFLAGS="$MPI_CFLAGS -DpgiFortran"
      ;;
  esac
  local NETCDF_SER_FLAGS="CFLAGS='$N_SER_CFLAGS' FCFLAGS='$FCFLAGS' FFLAGS='$FFLAGS' CXXFLAGS='$CXXFLAGS'"
  local NETCDF_PAR_FLAGS="CFLAGS='$N_PAR_CFLAGS' FCFLAGS='$MPI_FCFLAGS' FFLAGS='$MPI_FFLAGS' CXXFLAGS='$MPI_CXXFLAGS'"
  local NETCDF_BEN_FLAGS="$NETCDF_PAR_FLAGS"

# Additional args defined global to allow control over certain netcdf features
# The default args, below, have worked through the integration of fmcfm, uedge,
#   and nubeam
# BOUT++ uses netcdf-4 (and so hdf5).  To avoid symbol collitions, we need
#   to have --with-hdf5=$CONTRIB_DIR/hdf5-par
# BOUT++ also uses --enable-cxx.  So now want
  case $NETCDF_BLDRVERSION in
    3.*)
      ;;
    4.*)
# netcdf serial was building with serial hdf5, which was then a problem when
# linked against par codes such as fmcfm.
# JRC: --disable-netcdf-4 removes linking to hdf5, but we need this
#   for BOUT++, where we will have to use parallel HDF5 for serial I/O
# JRC: --disable-dap is for simplification
# JRC: --enable-shared does not work on freedom/hopper-pgi, so
#   do not add if disabled.
# JRC: --enable-cxx needed for BOUT++, transpnumeric.  Fails on pgi, so
#   must figure that out.
      if test -z "$HDF5_SER_DIR"; then
        if test -d "$CONTRIB_DIR/hdf5"; then
          HDF5_SER_DIR="$CONTRIB_DIR/hdf5"
        else
          techo "Cannot find hdf5.  Cannot build netcdf4."
          return 1
        fi
      fi
      NETCDF_SER_ADDL_ARGS="--disable-dap --enable-cxx --enable-netcdf-4 --enable-netcdf4 --with-hdf5=$HDF5_SER_DIR"
      if ! echo $NETCDF_SER_OTHER_ARGS | grep -q -- --disable-shared; then
        NETCDF_SER_ADDL_ARGS="$NETCDF_SER_ADDL_ARGS --enable-shared"
      fi
# BOUT++ uses the C++ bindings
      if test -z "$HDF5_PAR_DIR"; then
        if test -d "$CONTRIB_DIR/hdf5"; then
          HDF5_PAR_DIR="$CONTRIB_DIR/hdf5"
        else
          techo "Cannot find parallel hdf5.  Cannot build parallel netcdf4."
          return 1
        fi
      fi
      NETCDF_PAR_ADDL_ARGS="--disable-dap --enable-cxx --enable-netcdf-4 --enable-netcdf4 --with-hdf5=$HDF5_PAR_DIR"

      # This is to try to get the dependency for netCDF4 (think of as # pyNetCDF4)
      NETCDF_CC4PY_ADDL_ARGS="--enable-dap --enable-shared --enable-netcdf-4 --enable-netcdf4"
# Need curl config.  Netcdf is brain dead on this.
      local CURL_CONFIG=`which curl-config 2>/dev/null`
      if test -n "$CURL_CONFIG"; then
        NETCDF_CC4PY_ADDL_ARGS="$NETCDF_CC4PY_ADDL_ARGS --with-curl-config=$CURL_CONFIG"
      fi
# Parallel shared does not work on benten due to a libtool problem with
# the fortran libraries with gcc-4.6.0. So will not add.
# If you need shared, please document reason here.
# ben builds are never shared nor are they necdf-4 # NETCDF_BEN_ADDL_ARGS=
      ;;
  esac

# All builds
  if bilderUnpack -i netcdf; then

# Build serial
    if bilderConfig -i netcdf ser "$CONFIG_COMPILERS_SER $NETCDF_SER_FLAGS $NETCDF_LDFLAGS $CONFIG_HDF5_SER_DIR_ARG $NETCDF_SER_ADDL_ARGS $NETCDF_SER_OTHER_ARGS" "" "$NETCDF_ENV"; then
      bilderBuild -k netcdf ser
    fi

# Build parallel.  Needs to be static on verus.
    if bilderConfig -i netcdf par "$CONFIG_COMPILERS_PAR $NETCDF_PAR_FLAGS $NETCDF_PAR_LDFLAGS --disable-shared --enable-static $CONFIG_HDF5_PAR_DIR_ARG $NETCDF_PAR_ADDL_ARGS $NETCDF_PAR_OTHER_ARGS" "" "$NETCDF_PAR_ENV"; then
      rminterlibdeps	#  libtool gets this wrong.
      bilderBuild -k netcdf par "" "$NETCDF_PAR_ENV"
    fi

# Build for back-end nodes
    if bilderConfig -i netcdf ben "$CONFIG_COMPILERS_BEN $NETCDF_BEN_FLAGS $NETCDF_LDFLAGS $NETCDF_BEN_ADDL_ARGS $NETCDF_BEN_OTHER_ARGS" "" "$NETCDF_ENV"; then
      bilderBuild -k netcdf ben
    fi

# cc4py build is always shared
# Legacy naming irrelevant for cc4py builds
# On Windows, need $DISTUTILS_NOLV_ENV
    local NETCDF_CC4PY_ARG=`echo $CONFIG_HDF5_CC4PY_DIR_ARG | sed s/-dir//`
    if bilderConfig -i netcdf cc4py "$CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $NETCDF_LDFLAGS $NETCDF_CC4PY_FLAGS $NETCDF_CC4PY_ADDL_ARGS $NETCDF_CC4PY_ARG $CONFIG_HDF5_CC4PY_DIR_ARG" "" "$NETCDF_ENV"; then
      bilderBuild -k netcdf cc4py
    fi

  fi

}

######################################################################
#
# Test netcdf
#
######################################################################

testNetcdf() {
  techo "Not testing netcdf."
}

######################################################################
#
# Install netcdf
#
######################################################################

installNetcdf() {
  bilderInstall netcdf ser
  bilderInstall netcdf par
  bilderInstall netcdf ben
  bilderInstall netcdf cc4py
  # techo "WARNING: Quitting at end of netcdf.sh."; exit
}


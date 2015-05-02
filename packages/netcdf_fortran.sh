#!/bin/bash
#
# Build information for netcdf_fortran
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/netcdf_fortran_aux.sh
source $mydir/netcdf_aux.sh

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

setNetcdf_fortranGlobalVars() {
  if test -z "$NETCDF_FORTRAN_BUILDS"; then
    case `uname` in
      CYGWIN*) NETCDF_FORTRAN_BUILDS=NONE;;
      *) NETCDF_FORTRAN_BUILDS=ser,sersh,par;;  # Only parallel, with netcdf4 works
    esac
  fi
  NETCDF_FORTRAN_DEPS="netcdf,hdf5,cmake"
  NETCDF_FORTRAN_UMASK=002
}
setNetcdf_fortranGlobalVars

######################################################################
#
# Launch netcdf_fortran builds.
#
######################################################################

buildNetcdf_fortran() {

  if ! bilderUnpack netcdf_fortran; then
    return
  fi

# netcdf location specified by cppflags!
  local blddirvar=`genbashvar NETCDF_FORTRAN_${bld}`_DIR
  local nclsd=lib
  if test -d $NETCDF_SER_DIR/lib64; then
    nclsd=lib64
  fi
  NETCDF_FORTRAN_SER_ADDL_ARGS="${NETCDF_FORTRAN_ADDL_ARGS} CPPFLAGS='-I$NETCDF_SER_DIR/include' FCFLAGS='-I$NETCDF_SER_DIR/include' LIBS='-lnetcdf' LDFLAGS='-L$NETCDF_SER_DIR/$nclsd'"
  test -n "$FC" && NETCDF_FORTRAN_SER_ADDL_ARGS="FC=$FC ${NETCDF_FORTRAN_SER_ADDL_ARGS}"
  NETCDF_FORTRAN_SERSH_ADDL_ARGS="${NETCDF_FORTRAN_ADDL_ARGS} CPPFLAGS='-I$NETCDF_SERSH_DIR/include' FCFLAGS='-I$NETCDF_SERSH_DIR/include' LIBS='-lnetcdf'"
  case `uname` in
    Linux)
      NETCDF_FORTRAN_SERSH_ADDL_ARGS="${NETCDF_FORTRAN_SERSH_ADDL_ARGS} LDFLAGS='-L$NETCDF_SERSH_DIR/$nclsd -Wl,-rpath,$NETCDF_SERSH_DIR/$nclsd'"
      ;;
    *)
      NETCDF_FORTRAN_SERSH_ADDL_ARGS="${NETCDF_FORTRAN_SERSH_ADDL_ARGS} LDFLAGS='-L$NETCDF_SERSH_DIR/$nclsd'"
      ;;
  esac
  test -n "$FC" && NETCDF_FORTRAN_SERSH_ADDL_ARGS="FC='$FC' ${NETCDF_FORTRAN_SERSH_ADDL_ARGS}"
  NETCDF_FORTRAN_PAR_ADDL_ARGS="${NETCDF_FORTRAN_ADDL_ARGS} CPPFLAGS='-I$NETCDF_PAR_DIR/include' FCFLAGS='-I$NETCDF_PAR_DIR/include' LIBS='-lnetcdf LDFLAGS='-L$NETCDF_PAR_DIR/$nclsd'"
  test -n "$MPIFC" && NETCDF_FORTRAN_PAR_ADDL_ARGS="FC=$MPIFC ${NETCDF_FORTRAN_PAR_ADDL_ARGS}"

# Serial build
  if bilderConfig -p netcdf-${NETCDF_BLDRVERSION}-ser netcdf_fortran ser "--disable-shared --enable-static $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $MINGW_RC_COMPILER_FLAG $NETCDF_FORTRAN_SER_ADDL_ARGS $NETCDF_FORTRAN_SER_OTHER_ARGS"; then
    bilderBuild netcdf_fortran ser
  fi

  if bilderConfig -p netcdf-${NETCDF_BLDRVERSION}-sersh netcdf_fortran sersh "--disable-shared --enable-static $CONFIG_COMPILERS_SERSH $CONFIG_COMPFLAGS_SERSH $MINGW_RC_COMPILER_FLAG $NETCDF_FORTRAN_SERSH_ADDL_ARGS $NETCDF_FORTRAN_SERSHOTHER_ARGS"; then
    bilderBuild netcdf_fortran sersh
  fi

# Parallel build
  if bilderConfig -p netcdf-${NETCDF_BLDRVERSION}-par netcdf_fortran par "--disable-shared --enable-static $CONFIG_COMPILERS_PAR $CONFIG_COMPFLAGS_PAR $MINGW_RC_COMPILER_FLAG $NETCDF_FORTRAN_PAR_ADDL_ARGS $NETCDF_FORTRAN_PAR_OTHER_ARGS"; then
    bilderBuild netcdf_fortran par
  fi

}

######################################################################
#
# Test netcdf_fortran
#
######################################################################

testNetcdf_fortran() {
  techo "Not testing netcdf_fortran."
}

######################################################################
#
# Install netcdf_fortran
#
######################################################################

# Move the shared netcdf_fortran libraries to their legacy names.
# Allows shared and static to be installed in same place.
#
# 1: The installation directory
#
installNetcdf_fortran() {
  bilderInstallAll netcdf_fortran
}


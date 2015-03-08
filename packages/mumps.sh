#!/bin/bash
#
# Build information for mumps
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in mumps_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/mumps_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMumpsNonTriggerVars() {
  HYPRE_UMASK=002
  MUMPS_UMASK=002
}
setMumpsNonTriggerVars

#####################################################################
#
# Launch mumps builds
#
######################################################################

buildMumps() {
  if test -d $PROJECT_DIR/mumps; then
    getVersion mumps
    bilderPreconfig -c mumps
    res=$?
  else
    bilderUnpack mumps
    res=$?
  fi
  if test $res != 0; then
    return
  fi

# Shared: For Linux, add origin to rpath, do not strip rpath
  local MUMPS_SER_ADDL_ARGS=
  local MUMPS_SERSH_ADDL_ARGS=
  local MUMPS_PAR_ADDL_ARGS=
  local MUMPS_PARSH_ADDL_ARGS=
  case `uname` in
    Darwin)
# Shared libs to know their installation names so that builds of
# dependents link to this for installation to work without DYLD_LIBRARY_PATH
      MUMPS_SER_ADDL_ARGS="$MUMPS_SER_ADDL_ARGS -DMUMPS_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      MUMPS_PAR_ADDL_ARGS="$MUMPS_PAR_ADDL_ARGS -DMUMPS_BUILD_WITH_INSTALL_NAME:BOOL=TRUE"
      ;;
    Linux)
# Quoting of $ORIGIN does not work.
# Adding -Wl,-rpath,XORIGIN:XORIGIN/../lib to LINKER_FLAGS does not work.
# -DCMAKE_INSTALL_RPATH_USE_LINK_PATH cannot be used with -DCMAKE_INSTALL_RPATH
      MUMPS_SER_ADDL_ARGS="$MUMPS_SER_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$CONTRIB_DIR/mumps-${MUMPS_BLDRVERSION}-ser/lib:$LD_LIBRARY_PATH"
      MUMPS_PAR_ADDL_ARGS="$MUMPS_PAR_ADDL_ARGS -DCMAKE_INSTALL_RPATH:PATH=XORIGIN:XORIGIN/../lib:$CONTRIB_DIR/mumps-${MUMPS_BLDRVERSION}-par/lib:$LD_LIBRARY_PATH"
      ;;
  esac

  if bilderConfig mumps ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_SUPRA_SP_ARG $CMAKE_LINLIB_SER_ARGS $MUMPS_SER_ADDL_ARGS $MUMPS_SER_OTHER_ARGS"; then
    bilderBuild mumps ser
  fi
  if bilderConfig mumps par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $CMAKE_LINLIB_SER_ARGS $MUMPS_PAR_ADDL_ARGS $MUMPS_PAR_OTHER_ARGS"; then
    bilderBuild mumps par
  fi
}

######################################################################
#
# Test mumps
#
######################################################################

testMumps() {
  techo "Not testing mumps."
}

######################################################################
#
# Install mumps
#
######################################################################

installMumps() {
    for build in `echo $MUMPS_BUILDS | tr , " "`; do
      bilderInstall -r mumps $build
    done
}

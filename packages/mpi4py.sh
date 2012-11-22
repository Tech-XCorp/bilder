#!/bin/bash
#
# Version and build information for mpi4py
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MPI4PY_BLDRVERSION=${MPI4PY_BLDRVERSION:-"1.2.2"}

######################################################################
#
# Other values
#
######################################################################

MPI4PY_BUILDS=${MPI4PY_BUILDS:-"cc4py"}
# setuptools gets site-packages correct
MPI4PY_DEPS=Python,openmpi
MPI4PY_UMASK=002

#####################################################################
#
# Launch mpi4py builds.
#
######################################################################

buildMpi4py() {

  if bilderUnpack mpi4py; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/mpi4py*"
    techo "$cmd"
    $cmd

# Build away
    MPI4PY_ENV="$DISTUTILS_ENV"
    techo -2 MPI4PY_ENV = $MPI4PY_ENV
    bilderDuBuild -p mpi4py mpi4py "build_ext --inplace" "$MPI4PY_ENV"
  fi

}

######################################################################
#
# Test mpi4py
#
######################################################################

testMpi4py() {
  techo "Not testing mpi4py."
}

######################################################################
#
# Install mpi4py
#
######################################################################

installMpi4py() {
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p mpi4py mpi4py '-' "$MPI4PY_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p mpi4py mpi4py "--install-purelib=$PYTHON_SITEPKGSDIR" "$MPI4PY_ENV"
      ;;
  esac
}


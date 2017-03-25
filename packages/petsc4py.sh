#!/bin/sh
######################################################################
#
# @file    petsc4py.sh
#
# @brief   Version and build information for petsc4py.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

PETSC4PY_BLDRVERSION=${PETSC4PY_BLDRVERSION:-"1.2"}

######################################################################
#
# Other values
#
######################################################################

PETSC4PY_BUILDS=${PETSC4PY_BUILDS:-"pycsh"}
# setuptools gets site-packages correct
PETSC4PY_DEPS=setuptools,Python,petsc
PETSC4PY_UMASK=002

#####################################################################
#
# Launch petsc4py builds.
#
######################################################################

buildPetsc4py() {

  if bilderUnpack petsc4py; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/petsc4py*"
    techo "$cmd"
    $cmd

# Build away
    PETSC4PY_ENV="$DISTUTILS_ENV PETSC_DIR=$CONTRIB_DIR/petsc"
    techo -2 PETSC4PY_ENV = $PETSC4PY_ENV
    bilderDuBuild -p petsc4py petsc4py '-' "$PETSC4PY_ENV"
  fi

}

######################################################################
#
# Test petsc4py
#
######################################################################

testPetsc4py() {
  techo "Not testing petsc4py."
}

######################################################################
#
# Install petsc4py
#
######################################################################

installPetsc4py() {
  case `uname` in
    CYGWIN*)
# Windows does not have a lib versus lib64 issue
      bilderDuInstall -p petsc4py petsc4py '-' "$PETSC4PY_ENV"
      ;;
    *)
# For Unix, must install in correct lib dir
      # SWS/SK this is not generic and should be generalized in bildfcns.sh
      #        with a bilderDuInstallPureLib
      mkdir -p $PYTHON_SITEPKGSDIR
      bilderDuInstall -p petsc4py petsc4py "-" "$PETSC4PY_ENV"
      ;;
  esac
}


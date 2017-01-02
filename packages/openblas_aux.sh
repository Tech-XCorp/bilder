#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

getOpenblasTriggerVars() {

  OPENBLAS_BLDRVERSION_STD=${OPENBLAS_BLDRVERSION_STD:-"v0.2.19-2-gbcfc298"}
  OPENBLAS_BLDRVERSION_EXP=${OPENBLAS_BLDRVERSION_EXP:-"v0.2.19-2-gbcfc298"}

# Set the builds.
  if test -z "$OPENBLAS_DESIRED_BUILDS"; then
# Standard build of blas contains both ser and sersh
    OPENBLAS_DESIRED_BUILDS=sersh
    case `uname` in
      CYGWIN*)
        OPENBLAS_DESIRED_BUILDS="$OPENBLAS_DESIRED_BUILDS,sermd"
        ;;
    esac
  fi
  computeBuilds openblas
  addPycshBuild openblas

# Deps and other
  OPENBLAS_DEPS=

}
getOpenblasTriggerVars

######################################################################
#
# Find openblas
#
######################################################################

findOpenblas() {

# Find installation directories
  local srchbuilds="sersh"
  case `uname` in
    CYGWIN*)
      srchbuilds="$srchbuilds sermd"
      ;;
  esac
  findContribPackage Openblas openblas $srchbuilds
  findPycshDir Openblas

}


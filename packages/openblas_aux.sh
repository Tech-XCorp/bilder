#!/bin/sh
######################################################################
#
# @file    openblas_aux.sh
#
# @brief   Trigger vars and find information for openblas.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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
# Standard build of openblas contains both ser and sersh
    case `uname` in
      CYGWIN*)
        if which x86_64-w64-mingw32-gfortran.exe 2>/dev/null 1>&2; then
          OPENBLAS_DESIRED_BUILDS=sersh
        fi
      ;;

      *)
        OPENBLAS_DESIRED_BUILDS=ser
      ;;
    esac
  fi
  computeBuilds openblas

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
  findContribPackage Openblas openblas $srchbuilds
  findPycshDir Openblas

}

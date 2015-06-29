#!/bin/bash
#
# Trigger vars and find information for repo version 
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

setTrilinosgitTriggerVars() {

  TRILINOSGIT_REPO_URL=https://software.sandia.gov:/git
  TRILINOSGIT_REPO_BRANCH_STD=Trilinos
  TRILINOSGIT_REPO_BRANCH_EXP=Trilinos
  TRILINOSGIT_UPSTREAM_URL=https://software.sandia.gov:/git
  TRILINOSGIT_UPSTREAM_BRANCH=Trilinos
# To built the same way as python, uncomment next 2 lines
#  TRILINOSGIT_BUILD=$FORPYTHON_SHARED_BUILD
#  TRILINOSGIT_BUILDS=${TRILINOSGIT_BUILDS:-"$FORPYTHON_SHARED_BUILD"}

# Can add builds in package file only if no add builds defined.
  if test -z "$TRILINOSGIT_DESIRED_BUILDS"; then
    TRILINOSGIT_DESIRED_BUILDS="sercomm,parcomm"
    case `uname` in
      Darwin | Linux) TRILINOSGIT_DESIRED_BUILDS="${TRILINOSGIT_DESIRED_BUILDS},sercommsh,parcommsh";;
    esac
  fi
# Can remove builds based on OS here, as this decides what can build.
  case `uname` in
    CYGWIN*) TRILINOSGIT_NOBUILDS=${TRILINOSGIT_NOBUILDS},serbaresh,parbaresh,serfullsh,parfullsh,sercommsh,parcommsh;;
    Darwin) TRILINOSGIT_NOBUILDS=${TRILINOSGIT_NOBUILDS},parbaresh,parfullsh,parcommsh;;
  esac
  computeBuilds trilinos

# Add in superlu all the time.  May be needed elsewhere
  TRILINOSGIT_DEPS=${TRILINOSGIT_DEPS:-"mumps,superlu_dist,boost,$MPI_BUILD,superlu,swig,numpy,lapack"}

# commio builds depend on netcdf and hdf5.
# Only add in if these builds are present.
  if $BUILD_TRILINOSGIT_EXPERIMENTAL || echo "$TRILINOSGIT_BUILDS" | grep -q "commio" ; then
    TRILINOSGIT_DEPS="netcdf,hdf5,${TRILINOSGIT_DEPS}"
  fi
  case `uname` in
     CYGWIN*) ;;
     *)
       if echo ${TRILINOSGIT_DEPS} | grep -q "mumps" ; then
         TRILINOSGIT_DEPS="hypre,${TRILINOSGIT_DEPS}"
       else
         TRILINOSGIT_DEPS="hypre,mumps,${TRILINOSGIT_DEPS}"
       fi
       ;;
  esac

}
setTrilinosgitTriggerVars

######################################################################
#
# Find trilinosgit
#
######################################################################

findTrilinosgit() {
  :
}


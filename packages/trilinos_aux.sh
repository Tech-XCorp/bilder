#!/bin/bash
#
# Trigger vars and find information
#
# This is repacked to obey bilder conventions
# tar xzf trilinos-10.2.0-Source.tar.gz
# mv trilinos-10.2.0-Source trilinos-10.2.0
# tar czf trilinos-10.2.0.tar.gz trilinos-10.2.0
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

setTrilinosTriggerVars() {
# Versions
  TRILINOS_BLDRVERSION_STD=11.4.3
# 11.12.1 is the last version to configure and build with vs12
# But it does not build Zoltan?
  # TRILINOS_BLDRVERSION_EXP=11.12.1
  TRILINOS_BLDRVERSION_EXP=11.14.3
# Below fails to compile
# trilinos-12.0.1\packages\amesos\src\SuiteSparse\AMD\Source\amesos_amd_1.c
# cl : Command line error D8021 : invalid numeric argument '/Wno-all'
  # TRILINOS_BLDRVERSION_EXP=12.0.1
# Can add builds in package file only if no add builds defined.
  if test -z "$TRILINOS_DESIRED_BUILDS"; then
    TRILINOS_DESIRED_BUILDS="sercomm,parcomm"
    case `uname` in
      Darwin | Linux) TRILINOS_DESIRED_BUILDS="${TRILINOS_DESIRED_BUILDS},sercommsh,parcommsh";;
    esac
  fi
# Can remove builds based on OS here, as this decides what can build.
  case `uname` in
    CYGWIN*) TRILINOS_NOBUILDS=${TRILINOS_NOBUILDS},serbaresh,parbaresh,serfullsh,parfullsh,sercommsh,parcommsh;;
    Darwin) TRILINOS_NOBUILDS=${TRILINOS_NOBUILDS},parbaresh,parfullsh,parcommsh;;
  esac
  computeBuilds trilinos

# Add in superlu all the time.  May be needed elsewhere
  TRILINOS_DEPS=${TRILINOS_DEPS:-"mumps,superlu_dist,boost,$MPI_BUILD,superlu,swig,numpy,atlas,lapack"}
# commio builds depend on netcdf and hdf5.
# Only add in if these builds are present.
  if $BUILD_TRILINOS_EXPERIMENTAL || echo "$TRILINOS_BUILDS" | grep -q "commio" ; then
    TRILINOS_DEPS="netcdf,hdf5,${TRILINOS_DEPS}"
  fi
  case `uname` in
     CYGWIN*) ;;
     *)
       if echo ${TRILINOS_DEPS} | grep -q "mumps" ; then
         TRILINOS_DEPS="hypre,${TRILINOS_DEPS}"
       else
         TRILINOS_DEPS="hypre,mumps,${TRILINOS_DEPS}"
       fi
       ;;
  esac

}
setTrilinosTriggerVars

######################################################################
#
# Find trilinos
#
######################################################################

findTrilinos() {
  :
}


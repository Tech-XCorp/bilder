#!/bin/sh
######################################################################
#
# @file    trilinos_aux.sh
#
# @brief   Trigger vars and find information for trilinos.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
# This is repacked to obey bilder conventions
# tar xzf trilinos-10.2.0-Source.tar.gz
# mv trilinos-10.2.0-Source trilinos-10.2.0
# tar czf trilinos-10.2.0.tar.gz trilinos-10.2.0
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
  TRILINOS_BLDRVERSION_STD=11.14.3
# 11.12.1 is the last version to configure and build with vs12
# But it does not build Zoltan?
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
  TRILINOS_DEPS=${TRILINOS_DEPS:-"mumps,superlu_dist,boost,$MPI_BUILD,superlu,swig,numpy"}
# commio builds depend on netcdf and hdf5.
# Only add in if these builds are present.
  if echo "$TRILINOS_BUILDS" | grep -q "commio" ; then
    TRILINOS_DEPS="netcdf,hdf5,${TRILINOS_DEPS}"
  fi
  case `uname` in
    CYGWIN*)
      TRILINOS_DEPS="${TRILINOS_DEPS},clapack_cmake"
      ;;
    *)
      if echo ${TRILINOS_DEPS} | grep -q "mumps" ; then
        TRILINOS_DEPS="hypre,${TRILINOS_DEPS}"
      else
        TRILINOS_DEPS="hypre,mumps,${TRILINOS_DEPS}"
      fi
      TRILINOS_DEPS="${TRILINOS_DEPS},lapack"
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
# This needs to be generalized to find the library associated with each package
# requested in the build. For now, just find teuchos core as that always has to be built.
  local srchbuilds="serbare parbare sercomm parcomm sercommio parcommio serfull parfull"
  local srchbuilds="$srchbuilds serbaresh parbaresh sercommsh parcommsh sercommiosh parcommiosh"
  findPackage Trilinos teuchoscore "$BLDR_INSTALL_DIR" $srchbuilds
  techo
# Find cmake configuration directories
  for bld in $srcbuilds; do
    local blddirvar=`genbashvar TRILINOS_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/lib/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar TRILINOS_${bld}`_CMAKE_LIBDIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar TRILINOS_${bld}`_CMAKE_LIBDIR_ARG
      eval $varname="\"-DTrilinos_ROOT_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}


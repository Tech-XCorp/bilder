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
  TRILINOS_BLDRVERSION_EXP=11.4.3

# Can add builds in package file only if no add builds defined.
  if test -z "$TRILINOS_DESIRED_BUILDS"; then
    TRILINOS_DESIRED_BUILDS="serbare,parbare,sercomm,parcomm"
    case `uname` in
      CYGWIN* | Darwin) ;;
      Linux) TRILINOS_DESIRED_BUILDS="${TRILINOS_DESIRED_BUILDS},serbaresh,parbaresh,sercommsh,parcommsh,serfull,parfull,serfullsh,parfullsh";;
    esac
  fi
# Can remove builds based on OS here, as this decides what can build.
  case `uname` in
    CYGWIN* | Darwin) TRILINOS_NOBUILDS=${TRILINOS_NOBUILDS},serbaresh,parbaresh,serfullsh,parfullsh,sercommsh,parcommsh;;
  esac
  computeBuilds trilinos

# Add in superlu all the time.  May be needed elsewhere
  TRILINOS_DEPS=${TRILINOS_DEPS:-"superlu_dist,boost,openmpi,superlu,swig,numpy,atlas,lapack"}
# commio builds depend on netcdf and hdf5. Only add in if these builds are present.
  if echo "$TRILINOS_BUILDS" | grep -q "commio" ; then
    TRILINOS_DEPS="netcdf,hdf5,${TRILINOS_DEPS}"
  fi

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

#!/bin/bash
#
# Version and build information for lapack.
# The original tarball was obtained here:
#   http://www.netlib.org/lapack/lapack-3.4.0.tgz
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

setLapackTriggerVars() {
  LAPACK_BLDRVERSION_STD=${LAPACK_BLDRVERSION_STD="3.4.2"}
  LAPACK_BLDRVERSION_EXP=${LAPACK_BLDRVERSION_EXP="3.4.2"}
  computeVersion lapack
# We cannot rely on system builds, as they get the PIC flags wrong.
# Need liblapack.a compiled with -fPIC so that we can get the shared
# ATLAS library, which is needed for numpy.
  if $HAVE_SER_FORTRAN && test -z "$LAPACK_BUILDS"; then
    case `uname`-$CC in
      CYGWIN*-mingw*)
        LAPACK_BUILDS=ser,sersh,sermd
        addPycshBuild lapack
        ;;
      CYGWIN*) # If this works, consolidate with above
        LAPACK_BUILDS=ser,sersh,sermd
        addPycshBuild lapack
        ;;
      Darwin-*) # Darwin has -framework Accelerate
        LAPACK_BUILDS=NONE
        ;;
      Linux-*)
        LAPACK_BUILDS=ser,sersh
        addPycshBuild lapack
        addBenBuild lapack
        ;;
    esac
  fi
  trimvar LAPACK_BUILDS ','
  LAPACK_DEPS=cmake
}
setLapackTriggerVars

######################################################################
#
# Find lapack
#
######################################################################

findLapack() {
  LAPACK_INSTALLED=${LAPACK_INSTALLED:-"false"}
  if $LAPACK_INSTALLED; then
    findBlasLapack
  fi
}


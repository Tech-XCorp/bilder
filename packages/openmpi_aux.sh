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

setOpenmpiTriggerVars() {
  OPENMPI_BLDRVERSION_STD=1.6.5
  OPENMPI_BLDRVERSION_EXP=1.8.6
  if $BUILD_MPIS && test -z "$OPENMPI_BUILDS" && [[ $USE_MPI =~ openmpi ]]; then
    case `uname` in
      CYGWIN*) OPENMPI_BUILDS=nodl;;
      *) OPENMPI_BUILDS=nodl,static,shared;;
    esac
  fi
  OPENMPI_DEPS=libtool,automake
}
setOpenmpiTriggerVars

######################################################################
#
# Find openmpi
#
######################################################################

findOpenmpi() {
# Obtain correct mpi compiler names after bildall.sh is called
  if [[ "$USE_MPI" =~ openmpi ]] && test -d $CONTRIB_DIR/$USE_MPI/bin; then
    addtopathvar PATH $CONTRIB_DIR/$USE_MPI/bin
    local openmpidir=`(cd $CONTRIB_DIR/$USE_MPI/bin; pwd -P)`
    for c in MPICC MPICXX MPIFC MPIF77; do
      case $c in
        MPIFC) MPIFC=$openmpidir/mpif90;;
        *) exe=`echo $c | tr '[:upper:]' '[:lower:]'`; eval $c=$openmpidir/$exe;;
      esac
      exe=`deref $c`
      if ! test -x $exe; then
        techo "WARNING: $exe not found."
      fi
      printvar $c
    done
    OPENMPI_LIBDIR=`$MPICC -show | sed -e 's/^.*-L//' -e 's/ .*$//'`
    if test `uname` = Linux; then
      PAR_EXTRA_LDFLAGS="$PAR_EXTRA_LDFLAGS ${RPATH_FLAG}$OPENMPI_LIBDIR"
      PAR_EXTRA_LT_LDFLAGS="$PAR_EXTRA_LDFLAGS ${LT_RPATH_FLAG}$OPENMPI_LIBDIR"
    fi
    trimvar PAR_EXTRA_LDFLAGS ' '
    trimvar PAR_EXTRA_LT_LDFLAGS ' '
    printvar PAR_EXTRA_LDFLAGS
    printvar PAR_EXTRA_LT_LDFLAGS
    getCombinedCompVars
# Clean up bad links
    for i in $CONTRIB_DIR/openmpi*; do
      badlinks=`(cd $i; \ls -d openmpi* 2>/dev/null)`
      if test -n "$badlinks"; then
        badlinks=`(cd $i; rm -f openmpi*)`
      fi
    done
  fi
}


#!/bin/bash
#
# Version and build information for hypre (only build parallel for PETSc)
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

HYPRE_BLDRVERSION=${HYPRE_BLDRVERSION:-"2.8.3a"}

######################################################################
#
# Other values
#
######################################################################
if test -z "$HYPRE_BUILDS"; then
  HYPRE_BUILDS=par
  case `uname` in
    CYGWIN* | Darwin) ;;
    *) HYPRE_BUILDS="${HYPRE_BUILDS},parsh";;
  esac
fi

HYPRE_DEPS=cmake,atlas,lapack,clapack_cmake
HYPRE_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch hypre builds.
#
######################################################################

buildHypre() {
  if bilderUnpack hypre; then
    if bilderConfig -c hypre par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_NODEFLIB_FLAGS"; then
      bilderBuild hypre par
    fi
    if bilderConfig hypre parsh "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_NODEFLIB_FLAGS  -DHYPRE_SHARED:BOOL=ON"; then
      bilderBuild hypre parsh
    fi
  fi
}

######################################################################
#
# Test hypre
#
######################################################################

testHypre() {
  techo "Not testing hypre."
}

######################################################################
#
# Install hypre
#
######################################################################

installHypre() {
 for bld in sersh ser parsh par; do
    if bilderInstall -r hypre $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/hypre-$HYPRE_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}


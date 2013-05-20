#!/bin/bash
#
# Version and build information for hypre (only build parallel for PETSc)
# PETSc does not allow serial build w/hypre
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
  # Leaving serial build in case non-PETSc package needs it
  HYPRE_BUILDS=ser,par
  case `uname` in
    CYGWIN* | Darwin) ;;
    *) HYPRE_BUILDS="${HYPRE_BUILDS},sersh,parsh";;
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

    if bilderConfig -c hypre par "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TARBALL_NODEFLIB_FLAGS"; then
      bilderBuild hypre par
    fi

    if bilderConfig hypre parsh "$CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $TARBALL_NODEFLIB_FLAGS  -DHYPRE_SHARED:BOOL=ON"; then
      bilderBuild hypre parsh
    fi

    if bilderConfig -c hypre ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TARBALL_NODEFLIB_FLAGS"; then
      bilderBuild hypre ser
    fi

    if bilderConfig hypre sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $TARBALL_NODEFLIB_FLAGS  -DHYPRE_SHARED:BOOL=ON"; then
      bilderBuild hypre sersh
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


#!/bin/bash
#
# Version and build information for superlu
#
# $Id: superlu.sh 6364 2012-07-15 09:04:57Z cary $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SUPERLU_BLDRVERSION=${SUPERLU_BLDRVERSION:-"4.1"}

######################################################################
#
# Other values
#
######################################################################
if test -z "$SUPERLU_BUILDS"; then
  SUPERLU_BUILDS=ser
  case `uname` in
    CYGWIN* | Darwin) ;;
    *) SUPERLU_BUILDS="${SUPERLU_BUILDS},sersh";;
  esac
fi

SUPERLU_DEPS=cmake,atlas,lapack,clapack_cmake
SUPERLU_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

######################################################################
#
# Launch superlu builds.
#
######################################################################

buildSuperlu() {
  if bilderUnpack superlu; then
    if bilderConfig superlu ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS"; then
      bilderBuild superlu ser 
    fi
    if bilderConfig superlu sersh "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_NODEFLIB_FLAGS -DBUILD_SHARED_LIBS:BOOL=ON" ; then
      bilderBuild superlu sersh
    fi
  fi
}

######################################################################
#
# Test superlu
#
######################################################################

testSuperlu() {
  techo "Not testing superlu."
}

######################################################################
#
# Install superlu
#
######################################################################

installSuperlu() {
 for bld in sersh ser; do
    if bilderInstall -r superlu $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/superlu-$SUPERLU_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}


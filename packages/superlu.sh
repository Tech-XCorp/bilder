#!/bin/bash
#
# Version and build information for superlu
#
# $Id$
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
# Builds, deps, mask, auxdata, paths, builds of other packages
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
# Launch superlu builds.
#
######################################################################

buildSuperlu() {

  if test -d $PROJECT_DIR/superlu; then
    getVersion superlu
    bilderPreconfig -c superlu
    res=$?
  else
    bilderUnpack superlu
    res=$?
  fi

  if test $res != 0; then
    return
  fi

  if bilderConfig superlu ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_LINLIB_SER_ARGS $SUPERLU_SER_OTHER_ARGS"; then
    bilderBuild superlu ser
  fi
  if bilderConfig superlu sersh "-DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_LINLIB_SERSH_ARGS $SUPERLU_SERSH_OTHER_ARGS"; then
    bilderBuild superlu sersh
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
# JRC: code below does not make sense to me, as these are installed in separate directories
      # bldpre=`echo $bld | sed 's/sh$//'`
      # local instdir=$CONTRIB_DIR/superlu-$SUPERLU_BLDRVERSION-$bldpre
      local instdir=$CONTRIB_DIR/superlu-$SUPERLU_BLDRVERSION-$bld
      setOpenPerms $instdir
    fi
  done
}


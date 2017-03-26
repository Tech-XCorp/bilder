#!/bin/sh
######################################################################
#
# @file    superlu.sh
#
# @brief   Build information for superlu.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in superlu_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/superlu_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSuperluNonTriggerVars() {
  SUPERLU_UMASK=002
}
setSuperluNonTriggerVars

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


#!/bin/bash
#
# Build information for superlu_dist4
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in superlu_dist4_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/superlu_dist4_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSuperlu_Dist4NonTriggerVars() {
  SUPERLU_DIST4_UMASK=002
}
setSuperlu_Dist4NonTriggerVars

######################################################################
#
# Launch superlu_dist4 builds.
#
######################################################################

buildSuperlu_Dist4() {

  if test -d $PROJECT_DIR/superlu_dist4; then
    getVersion superlu_dist4
    bilderPreconfig -c superlu_dist4
    res=$?
  else
    bilderUnpack superlu_dist4
    res=$?
  fi

  if test $res != 0; then
    return
  fi

  if bilderConfig -c superlu_dist4 par "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_OpenMP:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST4_PAR_OTHER_ARGS"; then
    bilderBuild superlu_dist4 par
  fi
  if bilderConfig superlu_dist4 parsh "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_OpenMP:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST4_PARSH_OTHER_ARGS"; then
    bilderBuild superlu_dist4 parsh
  fi
  if bilderConfig -c superlu_dist4 parcomm "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_OpenMP:BOOL=TRUE -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST4_PARCOMM_OTHER_ARGS"; then
    bilderBuild superlu_dist4 parcomm
  fi
  if bilderConfig superlu_dist4 parcommsh "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_OpenMP:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST4_PARCOMMSH_OTHER_ARGS"; then
    bilderBuild superlu_dist4 parcommsh
  fi
  if bilderConfig -c superlu_dist4 ben "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_OpenMP:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE -DDISABLE_CPUCHECK:BOOL=TRUE $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $CMAKE_HDF5_BEN_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST4_BEN_OTHER_ARGS"; then
    bilderBuild superlu_dist4 ben
  fi

}

######################################################################
#
# Test superlu_dist4
#
######################################################################

testSuperlu_Dist4() {
  techo "Not testing superlu_dist4."
}

######################################################################
#
# Install superlu_dist4
#
######################################################################

installSuperlu_Dist4() {
  for bld in parcommsh parcomm parsh par ben; do
    if bilderInstall -r superlu_dist4 $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/superlu_dist4-$SUPERLU_DIST4_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}


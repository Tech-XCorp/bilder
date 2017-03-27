#!/bin/sh
######################################################################
#
# @file    superlu_dist5.sh
#
# @brief   Build information for superlu_dist5.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in superlu_dist5_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/superlu_dist5_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSuperlu_Dist5NonTriggerVars() {
  SUPERLU_DIST5_UMASK=002
}
setSuperlu_Dist5NonTriggerVars

######################################################################
#
# Launch superlu_dist5 builds.
#
######################################################################

buildSuperlu_Dist5() {

  if test -d $PROJECT_DIR/superlu_dist5; then
    getVersion superlu_dist5
    bilderPreconfig -c superlu_dist5
    res=$?
  else
    bilderUnpack superlu_dist5
    res=$?
  fi

  if test $res != 0; then
    return
  fi

  if bilderConfig -c superlu_dist5 par "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST5_PAR_OTHER_ARGS"; then
    bilderBuild superlu_dist5 par
  fi
  if bilderConfig superlu_dist5 parsh "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST5_PARSH_OTHER_ARGS"; then
    bilderBuild superlu_dist5 parsh
  fi
  if bilderConfig -c superlu_dist5 parcomm "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST5_PARCOMM_OTHER_ARGS"; then
    bilderBuild superlu_dist5 parcomm
  fi
  if bilderConfig superlu_dist5 parcommsh "-DENABLE_PARALLEL:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST5_PARCOMMSH_OTHER_ARGS"; then
    bilderBuild superlu_dist5 parcommsh
  fi
  if bilderConfig -c superlu_dist5 ben "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE -DDISABLE_CPUCHECK:BOOL=TRUE $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $CMAKE_HDF5_BEN_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST5_BEN_OTHER_ARGS"; then
    bilderBuild superlu_dist5 ben
  fi

}

######################################################################
#
# Test superlu_dist5
#
######################################################################

testSuperlu_Dist5() {
  techo "Not testing superlu_dist5."
}

######################################################################
#
# Install superlu_dist5
#
######################################################################

installSuperlu_Dist5() {
  for bld in parcommsh parcomm parsh par ben; do
    if bilderInstall -r superlu_dist5 $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/superlu_dist5-$SUPERLU_DIST5_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}


#!/bin/sh
######################################################################
#
# @file    superlu_dist3.sh
#
# @brief   Build information for superlu_dist3.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in superlu_dist3_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/superlu_dist3_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSuperluDist3NonTriggerVars() {
  SUPERLU_DIST3_UMASK=002
}
setSuperluDist3NonTriggerVars

######################################################################
#
# Launch superlu_dist3 builds.
#
######################################################################

buildSuperlu_Dist3() {

  if test -d $PROJECT_DIR/superlu_dist3; then
    getVersion superlu_dist3
    bilderPreconfig -c superlu_dist3
    res=$?
  else
    bilderUnpack superlu_dist3
    res=$?
  fi

  if test $res != 0; then
    return
  fi

  if bilderConfig -c superlu_dist3 par "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST3_PAR_OTHER_ARGS"; then
    bilderBuild superlu_dist3 par
  fi
  if bilderConfig superlu_dist3 parsh "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST3_PARSH_OTHER_ARGS"; then
    bilderBuild superlu_dist3 parsh
  fi
  if bilderConfig -c superlu_dist3 parcomm "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST3_PARCOMM_OTHER_ARGS"; then
    bilderBuild superlu_dist3 parcomm
  fi
  if bilderConfig superlu_dist3 parcommsh "-DENABLE_PARALLEL:BOOL=TRUE -DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_PARMETIS:BOOL=FALSE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_HDF5_PAR_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST3_PARCOMMSH_OTHER_ARGS"; then
    bilderBuild superlu_dist3 parcommsh
  fi
  if bilderConfig -c superlu_dist3 ben "-DENABLE_PARALLEL:BOOL=TRUE -DENABLE_PARMETIS:BOOL=TRUE -DDISABLE_CPUCHECK:BOOL=TRUE $CMAKE_COMPILERS_BEN $CMAKE_COMPFLAGS_BEN $CMAKE_HDF5_BEN_DIR_ARG $CMAKE_SUPRA_SP_ARG $SUPERLU_DIST3_BEN_OTHER_ARGS"; then
    bilderBuild superlu_dist3 ben
  fi

}

######################################################################
#
# Test superlu_dist3
#
######################################################################

testSuperlu_Dist3() {
  techo "Not testing superlu_dist3."
}

######################################################################
#
# Install superlu_dist3
#
######################################################################

installSuperlu_Dist3() {
  for bld in parcommsh parcomm parsh par ben; do
    if bilderInstall -r superlu_dist3 $bld; then
      bldpre=`echo $bld | sed 's/sh$//'`
      local instdir=$CONTRIB_DIR/superlu_dist3-$SUPERLU_DIST3_BLDRVERSION-$bldpre
      setOpenPerms $instdir
    fi
  done
}


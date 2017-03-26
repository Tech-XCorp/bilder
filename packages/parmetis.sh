#!/bin/sh
######################################################################
#
# @file    parmetis.sh
#
# @brief   Version and build information for parmetis.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in scotch_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/parmetis_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setParmetisNonTriggerVars() {
  PARMETIS_UMASK=002
}
setParmetisNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildParmetis() {
  local PARMETIS_CMAKE_COMPFLAGS_PAR="$CMAKE_COMPFLAGS_PAR -I/System/Library/Frameworks/Kernel.framework/Versions/A/Headers/sys/malloc.h"
  if bilderUnpack parmetis; then
    if bilderConfig parmetis par "-DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $PARMETIS_PAR_OTHER_ARGS"; then
      bilderBuild parmetis par
    fi
    if bilderConfig parmetis parsh "-DBUILD_SHARED_LIBS:BOOL=ON -DENABLE_PARALLEL:BOOL=TRUE $CMAKE_COMPILERS_PAR $CMAKE_COMPFLAGS_PAR $CMAKE_SUPRA_SP_ARG $PARMETIS_PAR_OTHER_ARGS"; then
      bilderBuild parmetis parsh
    fi
  fi
}

######################################################################
#
# Test
#
######################################################################

testParmetis() {
  techo "Not testing parmetis."
}

######################################################################
#
# Install
#
######################################################################

installParmetis() {
  bilderInstall parmetis par
  bilderInstall parmetis parsh
}


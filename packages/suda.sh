#!/bin/sh
######################################################################
#
# @file    suda.sh
#
# @brief   Build information for suda.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in suda_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/suda_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSudaNonTriggerVars() {
  SUDA_MASK=002
  SUDA_TESTING=${SUDA_TESTING:-"${TESTING_BUILDS}"}
  $SUDA_TESTING && SUDA_CTEST_MODEL=${SUDA_CTEST_MODEL:-"$BILDER_CTEST_MODEL"}
}
setSudaNonTriggerVars

######################################################################
#
# Launch suda builds.
#
######################################################################

buildSuda() {
  if ! bilderPreconfig -c suda; then
    return
  fi
  getVersion suda
  if bilderConfig -c suda $FORPYTHON_SHARED_BUILD "-DGeant4_DIR:PATH='$GEANT4_SERSH_CMAKE_DIR' -DUSE_OCE_SHARED:BOOL=TRUE $CMAKE_SUPRA_SP_ARG"; then
    bilderBuild suda $FORPYTHON_SHARED_BUILD
  fi
}

######################################################################
#
# Test suda
#
######################################################################

testSuda() {
  techo "No tests yet"
}

######################################################################
#
# Install suda
#
######################################################################

installSuda() {
  bilderInstallAll suda
}


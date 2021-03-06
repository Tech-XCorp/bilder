#!/bin/sh
######################################################################
#
# @file    pbr.sh
#
# @brief   Build information for pbr.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in pbr_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pbr_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPbrNonTriggerVars() {
  PBR_UMASK=002
}
setPbrNonTriggerVars

#####################################################################
#
# Launch builds.
#
######################################################################

buildPbr() {
  if ! bilderUnpack pbr; then
    return
  fi
  PBR_INSTALL_ARGS="--single-version-externally-managed --record='$PYTHON_SITEPKGSDIR/pbr.files'"
  # bilderDuBuild pbr "" "$DISTUTILS_ENV"
  bilderDuBuild pbr
}

######################################################################
#
# Test
#
######################################################################

testPbr() {
  techo "Not testing Pbr."
}

######################################################################
#
# Install
#
######################################################################

installPbr() {
  # bilderDuInstall pbr "$PBR_INSTALL_ARGS" "$DISTUTILS_ENV"
  bilderDuInstall pbr "$PBR_INSTALL_ARGS"
}


#!/bin/sh
######################################################################
#
# @file    xz.sh
#
# @brief   Build information for xz.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in xz_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/xz_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setXzNonTriggerVars() {
  XZ_UMASK=002
}
setXzNonTriggerVars

######################################################################
#
# Launch builds
#
######################################################################

buildXz() {
# Configure and build
  if ! bilderUnpack xz; then
    return
  fi
  if bilderConfig xz ser "" "" CC=gcc; then
    bilderBuild -m make xz ser "" "CC=gcc LD_RUN_PATH=$CONTRIB_DIR/xz-${XZ_BLDRVERSION}-ser/lib"
  fi
}

######################################################################
#
# Test
#
######################################################################

testXz() {
  techo "Not testing xz."
}

######################################################################
#
# Install
#
######################################################################

installXz() {
  bilderInstall xz ser
}


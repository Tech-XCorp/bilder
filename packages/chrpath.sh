#!/bin/sh
######################################################################
#
# @file    chrpath.sh
#
# @brief   Build information for chrpath.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in chrpath_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/chrpath_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setChrpathNonTriggerVars() {
  CHRPATH_UMASK=002
}
setChrpathNonTriggerVars

######################################################################
#
# Launch builds.
#
######################################################################

buildChrpath() {
  if ! bilderUnpack chrpath; then
    return
  fi
  if bilderConfig chrpath ser; then
    bilderBuild chrpath ser
  fi
}

######################################################################
#
# Test
#
######################################################################

testChrpath() {
  techo "Not testing chrpath."
}

######################################################################
#
# Install
#
######################################################################

installChrpath() {
  if bilderInstall chrpath ser; then
    mkdir -p $CONTRIB_DIR/bin
    (cd $CONTRIB_DIR/bin; ln -sf ../chrpath/bin/chrpath .)
  fi
}


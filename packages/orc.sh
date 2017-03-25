#!/bin/sh
######################################################################
#
# @file    orc.sh
#
# @brief   Build information for orc.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in orc_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/orc_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setOrcNonTriggerVars() {
  ORC_UMASK=002
}
setOrcNonTriggerVars

######################################################################
#
# Launch orc builds.
#
######################################################################

buildOrc() {
# Unpack
  if ! bilderUnpack orc; then
    return
  fi
# Build
  if bilderConfig orc sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $ORC_SER_OTHER_ARGS"; then
    bilderBuild orc sersh
  fi
  if bilderConfig orc pycsh "--enable-shared $CONFIG_COMPILERS_PYC $CONFIG_COMPFLAGS_PYC $ORC_SER_OTHER_ARGS"; then
    bilderBuild orc pycsh
  fi
}

######################################################################
#
# Test orc
#
######################################################################

testOrc() {
  techo "Not testing orc."
}

######################################################################
#
# Install orc
#
######################################################################

installOrc() {
  bilderInstall orc pycsh
  bilderInstall orc pycst
  bilderInstall orc sersh
}


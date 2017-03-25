#!/bin/sh
######################################################################
#
# @file    bison.sh
#
# @brief   Build information for bison.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in bison_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/bison_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setBisonNonTriggerVars() {
  BISON_UMASK=002
}
setBisonNonTriggerVars

######################################################################
#
# Launch bison builds.
#
######################################################################

buildBison() {
# Unpack
  if ! bilderUnpack bison; then
    return
  fi
# Build
  if bilderConfig bison sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $BISON_SER_OTHER_ARGS"; then
    bilderBuild bison sersh
  fi
}

######################################################################
#
# Test bison
#
######################################################################

testBison() {
  techo "Not testing bison."
}

######################################################################
#
# Install bison
#
######################################################################

installBison() {
  bilderInstall bison sersh
}


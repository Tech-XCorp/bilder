#!/bin/sh
######################################################################
#
# @file    flex.sh
#
# @brief   Documentation goes here.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2016-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

#!/bin/bash
#
# Build information for flex
#
# $Rev$ $Date$
#
######################################################################

######################################################################
#
# Trigger variables set in flex_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/flex_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setFlexNonTriggerVars() {
  FLEX_UMASK=002
}
setFlexNonTriggerVars

######################################################################
#
# Launch flex builds.
#
######################################################################

buildFlex() {
# Unpack
  if ! bilderUnpack flex; then
    return
  fi
# Build
  if bilderConfig flex sersh "--enable-shared $CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $FLEX_SER_OTHER_ARGS"; then
    bilderBuild flex sersh
  fi
  if bilderConfig flex ser "$CONFIG_COMPILERS_SER $CONFIG_COMPFLAGS_SER $FLEX_SER_OTHER_ARGS"; then
    bilderBuild flex ser
  fi
}

######################################################################
#
# Test flex
#
######################################################################

testFlex() {
  techo "Not testing flex."
}

######################################################################
#
# Install flex
#
######################################################################

installFlex() {
  bilderInstall flex sersh
  bilderInstall flex ser
}


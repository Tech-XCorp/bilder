#!/bin/sh
######################################################################
#
# @file    pcre.sh
#
# @brief   Build information for pcre.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in pcre_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pcre_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPcreNonTriggerVars() {
  PCRE_UMASK=002
}
setPcreNonTriggerVars

######################################################################
#
# Launch pcre builds.
#
######################################################################

buildPcre() {

# Check whether to install
  if ! bilderUnpack pcre; then
    return
  fi

# Whether using cmake
  if [[ `uname` =~ CYGWIN ]]; then
    PCRE_USE_CMAKE=true
  fi
# PCRE-8.20 built with cmake does not install pcre-config, which swig needs.
  PCRE_USE_CMAKE=${PCRE_USE_CMAKE:-"false"}
  local pcrecmakearg=
  if $PCRE_USE_CMAKE; then
    techo "Building PCRE with cmake."
    pcrecmakearg=-c
  else
    techo "Building PCRE with autotools."
  fi

  if bilderConfig $pcrecmakearg pcre ser; then
    bilderBuild pcre ser
  fi

}

######################################################################
#
# Test pcre
#
######################################################################

testPcre() {
  techo "Not testing pcre."
}

######################################################################
#
# Install pcre
#
######################################################################

installPcre() {
  bilderInstall -r pcre ser
}


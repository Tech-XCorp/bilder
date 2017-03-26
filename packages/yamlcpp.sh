#!/bin/sh
######################################################################
#
# @file    yamlcpp.sh
#
# @brief   Build information for yamlcpp library.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Version
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/yamlcpp_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setYamlcppNonTriggerVars() {
  YAMLCPP_UMASK=002
}
setYamlcppNonTriggerVars

######################################################################
#
# Launch yamlcpp builds.
#
######################################################################

buildYamlcpp() {

# Get moab from repo, determine whether to build
  updateRepo yamlcpp
  getVersion yamlcpp
  if ! bilderPreconfig -c yamlcpp; then
    return 1
  fi

  for bld in ${YAMLCPP_BUILDS}; do
      if bilderConfig -c yamlcpp $bld; then
        bilderBuild yamlcpp $bld
      fi
  done
}

######################################################################
#
# Test yamlcpp
#
######################################################################

testYamlcpp() {
  techo "Not testing yamlcpp."
}

######################################################################
#
# Install yamlcpp
#
######################################################################

installYamlcpp() {
  for bld in ${YAMLCPP_BUILDS}; do
    bilderInstall yamlcpp ${bld}
  done
}

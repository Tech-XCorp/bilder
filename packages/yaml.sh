#!/bin/sh
######################################################################
#
# @file    yaml.sh
#
# @brief   Build information for yaml library.
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
source $mydir/yaml_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setYamlNonTriggerVars() {
  YAML_UMASK=002
}
setYamlNonTriggerVars

######################################################################
#
# Launch yaml builds.
#
######################################################################

buildYaml() {
  if bilderUnpack yaml; then
    for bld in ${YAML_BUILDS}; do
      if bilderConfig yaml $bld; then
        bilderBuild yaml $bld
      fi
    done
  fi
}

######################################################################
#
# Test yaml
#
######################################################################

testYaml() {
  techo "Not testing yaml."
}

######################################################################
#
# Install yaml
#
######################################################################

installYaml() {
  for bld in ${YAML_BUILDS}; do
    bilderInstall yaml ${bld}
  done
}

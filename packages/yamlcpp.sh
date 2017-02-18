#!/bin/bash
#
# Version and build information for yamlcpp library.
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
# Putting the version information into moab_aux.sh eliminates the
# rebuild when one changes that file.  Of course, if the actual version
# changes, or this file changes, there will be a rebuild.  But with
# this one can change the experimental version without causing a rebuild
# in a non-experimental Bilder run.  One can also change any auxiliary
# functions without sparking a build.
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

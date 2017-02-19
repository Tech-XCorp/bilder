#!/bin/bash
#
# Version and build information for yaml library.
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

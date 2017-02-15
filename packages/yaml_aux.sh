#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setYamlTriggerVars() {
  YAML_BLDRVERSION=${YAML_BLDRVERSION:-"0.1.4"}
}
setYamlTriggerVars

######################################################################
#
# Find yaml
#
######################################################################

findYaml() {
  srchbuilds="ser sersh"
  findPackage Yaml YAML "$BLDR_INSTALL_DIR" $srchbuilds
  techo
  findPycshDir Yaml
  findPycstDir Yaml
  if test -n "$YAML_PYCSH_DIR"; then
    addtopathvar PATH ${YAML_PYCSH_DIR}/bin
  fi
  techo "Done with finding packages"
# Find cmake configuration directories
# This appends lib to the end of the CMAKE_BUILD_
  for bld in $srchbuilds; do
    local blddirvar=`genbashvar YAML_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      for subdir in lib; do
        if test -d $blddir/$subdir; then
          local dir=$blddir/$subdir
          if [[ `uname` =~ CYGWIN ]]; then
            dir=`cygpath -am $dir`
          fi
          local varname=`genbashvar YAML_${bld}`_CMAKE_LIBDIR
          eval $varname=$dir
          printvar $varname
          varname=`genbashvar YAML_${bld}`_CMAKE_LIBDIR_ARG
          eval $varname="\"-DYaml_ROOT_DIR:PATH='$dir'\""
          printvar $varname
          break
        fi
      done
    fi
  done
  techo "Done with defining variables"
}

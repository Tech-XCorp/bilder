#!/bin/sh
######################################################################
#
# @file    yamlcpp_aux.sh
#
# @brief   Trigger vars and find information for yamlcpp.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2017-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
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

setYamlcppTriggerVars() {
  YAMLCPP_REPO_URL=https://github.com/jbeder/yaml-cpp.git
  YAMLCPP_REPO_BRANCH_STD=master
  YAMLCPP_REPO_BRANCH_EXP=new-api

  YAMLCPP_DEPS=cmake

  if test -z "$YAMLCPP_DESIRED_BUILDS"; then
    YAMLCPP_DESIRED_BUILDS=ser
  fi
  computeBuilds yamlcpp

}
setYamlcppTriggerVars

######################################################################
#
# Find yamlcpp
#
######################################################################

findYamlcpp() {
  srchbuilds="ser sersh"
  findPackage Yamlcpp YAMLCPP "$BLDR_INSTALL_DIR" $srchbuilds
  techo
  findPycshDir Yamlcpp
  findPycstDir Yamlcpp
  if test -n "$YAMLCPP_PYCSH_DIR"; then
    addtopathvar PATH ${YAMLCPP_PYCSH_DIR}/bin
  fi
  techo "Done with finding packages"
# Find cmake configuration directories
# This appends lib to the end of the CMAKE_BUILD_
  for bld in $srchbuilds; do
    local blddirvar=`genbashvar YAMLCPP_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      for subdir in lib; do
        if test -d $blddir/$subdir; then
          local dir=$blddir/$subdir
          if [[ `uname` =~ CYGWIN ]]; then
            dir=`cygpath -am $dir`
          fi
          local varname=`genbashvar YAMLCPP_${bld}`_CMAKE_LIBDIR
          eval $varname=$dir
          printvar $varname
          varname=`genbashvar YAMLCPP_${bld}`_CMAKE_LIBDIR_ARG
          eval $varname="\"-DYamlcpp_ROOT_DIR:PATH='$dir'\""
          printvar $varname
          break
        fi
      done
    fi
  done
  techo "Done with defining variables"
}

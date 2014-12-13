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

setOceTriggerVars() {
  OCE_REPO_URL=https://github.com/Tech-XCorp/oce.git
  OCE_REPO_BRANCH_STD=OCE-0.15
  OCE_REPO_BRANCH_EXP=OCE-0.16.1-txc
  OCE_UPSTREAM_URL=https://github.com/tpaviot/oce.git
  OCE_UPSTREAM_BRANCH=OCE-0.16.1
  OCE_BUILD=$FORPYTHON_SHARED_BUILD
  OCE_BUILDS=${OCE_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  OCE_DEPS=freetype,cmake
}
setOceTriggerVars

######################################################################
#
# Find oce
#
######################################################################

findOce() {

# Look for Oce in the install directory
  findPackage Oce TKMath "$BLDR_INSTALL_DIR" pycsh sersh
  findPycshDir Oce

# Set root dir
  local ocerootdir=$OCE_PYCSH_DIR
  if test -z "$ocerootdir"; then
    return
  fi
# Convert to unix path for manipulations below
  if [[ `uname` =~ CYGWIN ]]; then
    ocerootdir=`cygpath -au $ocerootdir`
  fi
# Determine where the cmake config files are
  ocever=`basename $ocerootdir | sed -e 's/^oce-//' -e 's/^OCE-//' -e "s/-$OCE_BUILD$//"`
  techo "Found OCE of version $ocever." 1>&2
  local ocecmakedir=
  case `uname` in
    CYGWIN*)
      ocecmakedir=${ocerootdir}/cmake
      ;;
    Darwin)
      for dir in ${ocerootdir}/OCE.framework/Versions/{$ocever,${ocever}-dev,*}; do
        if test -d $dir; then
          ocecmakedir=$dir/Resources
          break
        fi
      done
      ;;
    Linux)
      for dir in ${ocerootdir}/lib/{oce-$ocever,oce-${ocever}-dev,oce-*}; do
        if test -d $dir; then
          ocecmakedir=$dir
          break
        fi
      done
      ;;
  esac
  if test -z "$ocecmakedir"; then
    return
  fi

# Set additional variables
  if [[ `uname` =~ CYGWIN ]]; then
    ocecmakedir=`cygpath -am $ocecmakedir`
  fi
  OCE_PYCSH_CMAKE_DIR="$ocecmakedir"
  OCE_PYCSH_CMAKE_DIR_ARG="-DOCE_DIR:PATH='$ocecmakedir'"
  printvar OCE_PYCSH_CMAKE_DIR
  printvar OCE_PYCSH_CMAKE_DIR_ARG

}


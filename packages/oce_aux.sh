#!/bin/sh
######################################################################
#
# @file    oce_aux.sh
#
# @brief   Trigger vars and find information for oce.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
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

setOceTriggerVars() {
# Remove old repo
  if test -d $PROJECT_DIR/oce; then
    newocerem=`(cd $PROJECT_DIR/oce; git remote -v | grep Tech-XCorp)`
    if test -z "$newocerem"; then
      rm -rf $PROJECT_DIR/oce
    fi
  fi
# Standard vars
  OCE_REPO_URL=https://github.com/Tech-XCorp/oce.git
# We do not follow https://internal.txcorp.com/it/wiki/UpstreamGit
# precisely, because we want to work off their tags.  So instead
# we make a local branch, e.g., OCE-0.17.1-txc, and work from that.
# The older branch is mirrored at stable.
  OCE_REPO_BRANCH_STD=${OCE_REPO_BRANCH_STD:-"stable"} # aka OCE-0.17-txc
  OCE_REPO_BRANCH_EXP=${OCE_REPO_BRANCH_EXP:-"develop"}
# Reverting, as this branch caused a step file reading crash
  OCE_REPO_BRANCH_EXP=${OCE_REPO_BRANCH_EXP:-"stable"}
  OCE_UPSTREAM_URL=https://github.com/tpaviot/oce.git
  OCE_UPSTREAM_BRANCH_STD=OCE-0.17
  OCE_UPSTREAM_BRANCH_EXP=OCE-0.17.1
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


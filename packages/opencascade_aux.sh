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

setOpenCascadeTriggerVars() {
# Remove old repo
  if test -d $PROJECT_DIR/opencascade; then
    newopencascaderem=`(cd $PROJECT_DIR/opencascade; git remote -v | grep Tech-XCorp)`
    if test -z "$newopencascaderem"; then
      rm -rf $PROJECT_DIR/opencascade
    fi
  fi
# Standard vars
  OPENCASCADE_REPO_URL=https://github.com/Tech-XCorp/opencascade.git
# We do not follow https://internal.txcorp.com/it/wiki/UpstreamGit
# precisely, because we want to work off their tags.  So instead
# we make a local branch, e.g., OPENCASCADE-0.17.1-txc, and work from that.
# The older branch is mirrored at stable.
  OPENCASCADE_REPO_BRANCH_STD=${OPENCASCADE_REPO_BRANCH_STD:-"stable"} # aka OPENCASCADE-0.17-txc
  OPENCASCADE_REPO_BRANCH_EXP=${OPENCASCADE_REPO_BRANCH_EXP:-"develop"}
# Reverting, as this branch caused a step file reading crash
  OPENCASCADE_REPO_BRANCH_EXP=${OPENCASCADE_REPO_BRANCH_EXP:-"stable"}
  OPENCASCADE_UPSTREAM_URL=https://github.com/tpaviot/opencascade.git
  OPENCASCADE_UPSTREAM_BRANCH_STD=OPENCASCADE-0.17
  OPENCASCADE_UPSTREAM_BRANCH_EXP=OPENCASCADE-0.17.1
  OPENCASCADE_BUILD=$FORPYTHON_SHARED_BUILD
  OPENCASCADE_BUILDS=${OPENCASCADE_BUILDS:-"$FORPYTHON_SHARED_BUILD"}
  OPENCASCADE_DEPS=freetype,cmake
}
setOpenCascadeTriggerVars

######################################################################
#
# Find opencascade
#
######################################################################

findOpenCascade() {

# Look for OpenCascade in the install directory
  findPackage OpenCascade TKMath "$BLDR_INSTALL_DIR" pycsh sersh
  findPycshDir OpenCascade

# Set root dir
  local opencascaderootdir=$OPENCASCADE_PYCSH_DIR
  if test -z "$opencascaderootdir"; then
    return
  fi
# Convert to unix path for manipulations below
  if [[ `uname` =~ CYGWIN ]]; then
    opencascaderootdir=`cygpath -au $opencascaderootdir`
  fi
# Determine where the cmake config files are
  opencascadever=`basename $opencascaderootdir | sed -e 's/^opencascade-//' -e 's/^OPENCASCADE-//' -e "s/-$OPENCASCADE_BUILD$//"`
  techo "Found OPENCASCADE of version $opencascadever." 1>&2
  local opencascadecmakedir=
  case `uname` in
    CYGWIN*)
      opencascadecmakedir=${opencascaderootdir}/cmake
      ;;
    Darwin)
      for dir in ${opencascaderootdir}/OPENCASCADE.framework/Versions/{$opencascadever,${opencascadever}-dev,*}; do
        if test -d $dir; then
          opencascadecmakedir=$dir/Resources
          break
        fi
      done
      ;;
    Linux)
      for dir in ${opencascaderootdir}/lib/{opencascade-$opencascadever,opencascade-${opencascadever}-dev,opencascade-*}; do
        if test -d $dir; then
          opencascadecmakedir=$dir
          break
        fi
      done
      ;;
  esac
  if test -z "$opencascadecmakedir"; then
    return
  fi

# Set additional variables
  if [[ `uname` =~ CYGWIN ]]; then
    opencascadecmakedir=`cygpath -am $opencascadecmakedir`
  fi
  OPENCASCADE_PYCSH_CMAKE_DIR="$opencascadecmakedir"
  OPENCASCADE_PYCSH_CMAKE_DIR_ARG="-DOPENCASCADE_DIR:PATH='$opencascadecmakedir'"
  printvar OPENCASCADE_PYCSH_CMAKE_DIR
  printvar OPENCASCADE_PYCSH_CMAKE_DIR_ARG

}


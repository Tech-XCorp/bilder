#!/bin/bash
#
# Version and find information for oce
#
# $Id$
#
######################################################################

getOceVersion() {
  # OCE_BLDRVERSION=${OCE_BLDRVERSION:-"0.10.1-r747"}
  OCE_REPO_URL=git://github.com/tpaviot/oce.git
  OCE_UPSTREAM_URL=git://github.com/tpaviot/oce.git
  OCE_REPO_TAG_STD=OCE-0.14.1
  OCE_REPO_TAG_EXP=OCE-0.15
}
getOceVersion

######################################################################
#
# Find oce
#
######################################################################

# Find the directory containing the OCE cmake files
findOce() {

# Look for Oce in the contrib directory
  findPackage Oce TKMath cc4py sersh
# Pick from non-empty of OCE_CC4PY_DIR OCE_SERSH_DIR
  local ocerootdir=$OCE_CC4PY_DIR
  ocerootdir=${ocedir:-"$OCE_SERSH_DIR"}
  if test -z "$ocerootdir"; then
    return
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
  OCE_CC4PY_CMAKE_DIR="$ocecmakedir"
  OCE_CC4PY_CMAKE_DIR_ARG="-DOCE_DIR:PATH='$ocecmakedir'"
  printvar OCE_CC4PY_CMAKE_DIR
  printvar OCE_CC4PY_CMAKE_DIR_ARG

}


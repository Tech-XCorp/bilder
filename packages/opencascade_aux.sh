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
  OPENMPI_BLDRVERSION_STD=7.1.0
  OPENMPI_BLDRVERSION_EXP=7.1.0
  OPENCASCADE_BUILDS=shared
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


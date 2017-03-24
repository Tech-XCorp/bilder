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

setArmadilloTriggerVars() {

  ARMADILLO_BLDRVERSION_STD=${ARMADILLO_BLDRVERSION_STD:-"7.800.2"}
  ARMADILLO_BLDRVERSION_EXP=${ARMADILLO_BLDRVERSION_EXP:-"7.800.2"}

  if test -z "$ARMADILLO_DESIRED_BUILDS"; then
    ARMADILLO_DESIRED_BUILDS=ser,par,sersh
    if [[ `uname` =~ CYGWIN ]]; then
      ARMADILLO_DESIRED_BUILDS="${ARMADILLO_DESIRED_BUILDS},sermd"
    fi
  fi
  computeBuilds armadillo
  ARMADILLO_DEPS=hdf5,$MPI_BUILD,lapack
  if echo $DOCS_BUILDS | egrep -q "(^|,)develdocs($|,)"; then
    ARMADILLO_DEPS=${ARMADILLO_DEPS},doxygen
  fi
}
setArmadilloTriggerVars

######################################################################
#
# Find armadillo
#
######################################################################

findArmadillo() {
  srchbuilds="ser sersh par"
  findPackage Armadillo ARMADILLO "$BLDR_INSTALL_DIR" $srchbuilds
  techo
# Find cmake configuration directories
  for bld in $srcbuilds; do
    local blddirvar=`genbashvar ARMADILLO_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/lib/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar ARMADILLO_${bld}`_CMAKE_LIBDIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar ARMADILLO_${bld}`_CMAKE_LIBDIR_ARG
      eval $varname="\"-DArmadillo_ROOT_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}


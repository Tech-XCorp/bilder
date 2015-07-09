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

setTxbaseTriggerVars() {
  if test -z "$TXBASE_DESIRED_BUILDS"; then
    TXBASE_DESIRED_BUILDS=ser,par,sersh
    if [[ `uname` =~ CYGWIN ]]; then
      TXBASE_DESIRED_BUILDS="${TXBASE_DESIRED_BUILDS},sermd"
    fi
    if echo $DOCS_BUILDS | egrep -q "(^|,)develdocs($|,)"; then
      TXBASE_DESIRED_BUILDS=$TXBASE_DESIRED_BUILDS,develdocs
    fi
  fi
  computeBuilds txbase
  addPycstBuild txbase
  addPycshBuild txbase
  TXBASE_DEPS=hdf5,$MPI_BUILD,boost,Python,cmake,doxygen,cppcheck
}
setTxbaseTriggerVars

######################################################################
#
# Find txbase
#
######################################################################

findTxbase() {
  srchbuilds="ser sersh par"
  findPackage TxBase TXBASE "$BLDR_INSTALL_DIR" $srchbuilds
  techo
# Find cmake configuration directories
  for bld in $srcbuilds; do
    local blddirvar=`genbashvar TXBASE_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/lib/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar TXBASE_${bld}`_CMAKE_LIBDIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar TXBASE_${bld}`_CMAKE_LIBDIR_ARG
      eval $varname="\"-DTxBase_ROOT_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}


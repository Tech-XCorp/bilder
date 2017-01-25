#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
##################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setTxphysicsTriggerVars() {
# txphysics used only by engine, so no sersh build needed
  TXPHYSICS_BUILDS=${TXPHYSICS_BUILDS:-"ser"}
  computeBuilds txphysics
  addBenBuild txphysics
  TXPHYSICS_DEPS=cmake
}
setTxphysicsTriggerVars

######################################################################
#
# Find txphysics
#
######################################################################

findTxphysics() {
  srchbuilds="ser"
  findPackage TxPhysics TXPHYSICS "$BLDR_INSTALL_DIR" $srchbuilds
  techo
# Find cmake configuration directories
  for bld in $srcbuilds; do
    local blddirvar=`genbashvar TXPHYSICS_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/lib/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar TXPHYSICS_${bld}`_CMAKE_LIBDIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar TXPHYSICS_${bld}`_CMAKE_LIBDIR_ARG
      eval $varname="\"-DTxPhysics_ROOT_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}


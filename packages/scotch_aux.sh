#!/bin/sh
######################################################################
#
# @file    scotch_aux.sh
#
# @brief   Trigger vars and find information for scotch.
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

setScotchTriggerVars() {
  SCOTCH_BLDRVERSION_STD=6.0.4
  SCOTCH_BLDRVERSION_EXP=6.0.4
  if test -z "$SCOTCH_BUILDS"; then
    SCOTCH_BUILDS=par
    case `uname` in
      CYGWIN*) ;;
      Darwin) SCOTCH_BUILDS="${SCOTCH_BUILDS}";;
      Linux) SCOTCH_BUILDS="${SCOTCH_BUILDS}";;
    esac
  fi
  SCOTCH_DEPS=autotools,$MPI_BUILD
}
setScotchTriggerVars

######################################################################
#
# Find scotch
#
######################################################################

findScotch() {
# Find installation directories
  findContribPackage Scotch scotch par
  local builds="par"
  techo

# Find cmake configuration directories
  techo
  for bld in $builds; do
    local blddirvar=`genbashvar SCOTCH_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/share/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar SCOTCH_${bld}`_CMAKE_DIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar SCOTCH_${bld}`_CMAKE_DIR_ARG
      eval $varname="\"-DScotch_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}


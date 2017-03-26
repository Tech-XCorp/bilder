#!/bin/sh
######################################################################
#
# @file    parmetis_aux.sh
#
# @brief   Trigger vars and find information for parmetis.
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

setParmetisTriggerVars() {
  PARMETIS_BLDRVERSION_STD=4.0.3
  PARMETIS_BLDRVERSION_EXP=4.0.3
  if test -z "$PARMETIS_BUILDS"; then
    case `uname` in
      CYGWIN*) ;;
      Linux) PARMETIS_BUILDS=par,parsh;;
      Darwin) PARMETIS_BUILDS=par;;
    esac
  fi
  PARMETIS_DEPS=autotools,$MPI_BUILD
}
setParmetisTriggerVars

######################################################################
#
# Find parmetis
#
######################################################################

findParmetis() {
# Find installation directories
  findContribPackage Parmetis parmetis par
  local builds="par"
  techo

# Find cmake configuration directories
  techo
  for bld in $builds; do
    local blddirvar=`genbashvar PARMETIS_${bld}`_DIR
    local blddir=`deref $blddirvar`
    if test -d "$blddir"; then
      local dir=$blddir/share/cmake
      if [[ `uname` =~ CYGWIN ]]; then
        dir=`cygpath -am $dir`
      fi
      local varname=`genbashvar PARMETIS_${bld}`_CMAKE_DIR
      eval $varname=$dir
      printvar $varname
      varname=`genbashvar PARMETIS_${bld}`_CMAKE_DIR_ARG
      eval $varname="\"-DParmetis_DIR:PATH='$dir'\""
      printvar $varname
    fi
  done
}


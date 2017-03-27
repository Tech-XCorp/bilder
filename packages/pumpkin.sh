#!/bin/sh
######################################################################
#
# @file    pumpkin.sh
#
# @brief   Build information for pumpkin.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2015-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in pumpkin_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/pumpkin_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setPumpkinNonTriggerVars() {
  PUMPKIN_MASK=002
}
setPumpkinNonTriggerVars

######################################################################
#
# Launch pumpkin builds.
#
######################################################################

# Build pumpkin using cmake
buildPumpkin() {
# Check for svn version or package
  bilderUnpack pumpkin
  res=$?
  if test $res = 0; then
    local PUMPKIN_ENVVARS=
    case `uname`-$CC in
      CYGWIN*-mingw*)
        local mingwgcc=`which mingw32-gcc`
        local mingwdir=`dirname $mingwgcc`
        PUMPKIN_ENVVARS="PATH='$mingwdir:$PATH'"
        ;;
    esac
# Serial build
    if bilderConfig -c pumpkin ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $CMAKE_LINLIB_SER_ARGS $PUMPKIN_SER_OTHER_ARGS $CMAKE_SUPRA_SP_ARG"; then
      bilderBuild pumpkin ser "" "$PUMPKIN_ENVVARS"
    fi
  fi
}

######################################################################
#
# Test pumpkin
#
######################################################################

testPumpkin() {
  techo "Not testing pumpkin."
}

######################################################################
#
# Install pumpkin
#
######################################################################

installPumpkin() {
  bilderInstall pumpkin ser
}


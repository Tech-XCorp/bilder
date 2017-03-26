#!/bin/sh
######################################################################
#
# @file    swig.sh
#
# @brief   Build information for swig.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2012-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in swig_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/swig_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setSwigNonTriggerVars() {
  SWIG_UMASK=002
}
setSwigNonTriggerVars

######################################################################
#
# Launch swig builds.
#
######################################################################

buildSwig() {

# Unpack if needed
  if ! bilderUnpack swig; then
    return
  fi

# Should build
  if bilderConfig swig ser; then
    case `uname` in
      Linux) local SWIG_MAKE_ENV=LD_RUN_PATH=`(cd $CONTRIB_DIR/pcre/lib; pwd -P)`;; # Fix rpath
    esac
    bilderBuild swig ser "$SWIG_MAKE_ENV"
  fi

}

######################################################################
#
# Test swig
#
######################################################################

testSwig() {
  techo "Not testing swig."
}

######################################################################
#
# Install swig
#
######################################################################

installSwig() {
  bilderInstall -r swig ser swig
}


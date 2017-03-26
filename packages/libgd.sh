#!/bin/sh
######################################################################
#
# @file    libgd.sh
#
# @brief   Build information for libgd.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2014-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

######################################################################
#
# Trigger variables set in libgd_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/libgd_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setLibgdNonTriggerVars() {
  LIBGD_UMASK=002
}
setLibgdNonTriggerVars

######################################################################
#
# Launch libgd builds.
#
######################################################################

buildLibgd() {

  if ! bilderUnpack libgd; then
    return 1
  fi

# We could build libgd with these flags, but we would still not have
# gdlib-config, which graphviz needs to know the features of libgd.
  # -DPNG_PNG_INCLUDE_DIR:PATH=/opt/homebrew/include \
  # -DPNG_LIBRARY:FILEPATH=/opt/homebrew/lib/libpng16.dylib
  if bilderConfig -c libgd ser "$CMAKE_COMPILERS_SER $CMAKE_COMPFLAGS_SER $LIBGD_SER_ADDL_ARGS $LIBGD_SER_OTHER_ARGS"; then
    bilderBuild libgd ser
  fi

}

######################################################################
#
# Test libgd
#
######################################################################

testLibgd() {
  techo "Not testing libgd."
}

######################################################################
#
# Install libgd
#
######################################################################

installLibgd() {
  bilderInstallAll libgd
}


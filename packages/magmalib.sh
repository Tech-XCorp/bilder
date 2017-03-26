#!/bin/sh
######################################################################
#
# @file    magmalib.sh
#
# @brief   Version and build information for Magmalib.
#
# @version $Rev$ $Date$
#
# Copyright &copy; 2013-2017, Tech-X Corporation, Boulder, CO.
# See LICENSE file (EclipseLicense.txt) for conditions of use.
#
######################################################################

MAGMALIB_BLDRVERSION=${MAGMALIB_BLDRVERSION:-"1.4.0.2-tx-win64-tesla"}
MAGMALIB_BUILDS=${MAGMALIB_BUILDS:-"gpu"}
MAGMALIB_DEPS=
MAGMALIB_UMASK=002

#####################################################################
#
# Launch Magmalib builds.
#
######################################################################

# This currently only installs the windows tesla 64 bit magma library

buildMagmalib() {
  techo ""
  if shouldInstall -i $CONTRIB_DIR magmalib-$MAGMALIB_BLDRVERSION gpu; then
    # local magmalibtarball=`getPkg "magmalib-$MAGMALIB_BLDRVERSION"`
    getPkg magmalib-$MAGMALIB_BLDRVERSION
    local magmalibtarball="$GETPKG_RETURN"
    cmd="$TAR -C $CONTRIB_DIR -xzf $magmalibtarball"
    $cmd
    cmd="mkLink $CONTRIB_DIR magmalib-$MAGMALIB_BLDRVERSION magmalib"
    $cmd
    cmd="$BILDER_DIR/setinstald.sh -i $CONTRIB_DIR magmalib,gpu"
    $cmd
    buildSuccesses="$buildSuccesses magmalib"
  fi
}

testMagmalib() {
  techo "Not testing Magmalib."
}

installMagmalib() {
  : # bilderInstall Magmalib
}

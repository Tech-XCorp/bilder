#!/bin/bash
#
# Version and build information for Magmalib
#
# $Id$
#
######################################################################

MAGMALIB_BLDRVERSION=${MAGMALIB_BLDRVERSION:-"1.3.0"}
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
  if shouldInstall -i $CONTRIB_DIR magmalib-${MAGMALIB_BLDRVERSION} gpu; then
    local os=
    case `uname` in
      CYGWIN*) os=win64;;
      Darwin) os=osx64;;
      Linux) os=linux64;;
      *) techo "Catastrophic error.  OS unknown."; exit;;
    esac
	local gpu="tesla"
    local magmalibtarball="$PROJECT_DIR/../bilderpkgs/magmalib-${MAGMALIB_BLDRVERSION}-${os}-${gpu}.tar.gz"
    getPkg "magmalib-${MAGMALIB_BLDRVERSION}-${os}-${gpu}"
#    local cmd="svn up ${magmalibtarball}"
#    $cmd
    cmd="${TAR} -C $CONTRIB_DIR -xzf ${magmalibtarball}"
    $cmd
#    cmd="rmall $CONTRIB_DIR/magmalib-${MAGMALIB_BLDRVERSION}-gpu magmalib"
#    $cmd
#    cmd="mv $CONTRIB_DIR/magmalib-${MAGMALIB_BLDRVERSION}-${os}-${gpu} $CONTRIB_DIR/magmalib-${MAGMALIB_BLDRVERSION}-gpu"
#    $cmd
#    cmd="setOpenPerms $CONTRIB_DIR/magmalib-${MAGMALIB_BLDRVERSION}-${os}-${gpu}"
#    $cmd
    cmd="mkLink $CONTRIB_DIR magmalib-${MAGMALIB_BLDRVERSION}-${os}-${gpu} magmalib"
    $cmd
#	cmd="ln -s $CONTRIB_DIR/magmalib-${MAGMALIB_BLDRVERSION}-${os}-${gpu} $CONTRIB_DIR/magmalib"
#    $cmd
    cmd="$BILDER_DIR/setinstald.sh -i $CONTRIB_DIR magmalib,${os}-${gpu}"
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

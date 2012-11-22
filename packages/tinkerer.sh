#!/bin/bash
#
# Version and build information for tinkerer
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

TINKERER_BLDRVERSION=${TINKERER_BLDRVERSION:-"0.3b"}

######################################################################
#
# Other values
#
######################################################################

TINKERER_BUILDS=${TINKERER_BUILDS:-"cc4py"}
TINKERER_DEPS=sphinx
TINKERER_UMASK=002

######################################################################
#
# Add to paths.  Why both?  (JRC) removing second.
#
######################################################################

case `uname` in
  CYGWIN*)
    addtopathvar PATH $CONTRIB_DIR/Scripts
    ;;
  *)
    addtopathvar PATH $CONTRIB_DIR/bin
    ;;
esac
# addtopathvar PATH $BLDR_INSTALL_DIR/bin

#####################################################################
#
# Launch tinkerer builds.
#
######################################################################

buildTinkerer() {

  if bilderUnpack tinkerer; then
# Remove all old installations
    cmd="rm -rf ${PYCONTDIR}/tinkerer*"
    techo "$cmd"
    $cmd

# Build away
    TINKERER_ENV="$DISTUTILS_ENV $TINKERER_GFORTRAN"
    techo -2 TINKERER_ENV = $TINKERER_ENV
    bilderDuBuild -p tinkerer tinkerer '-' "$TINKERER_ENV"
  fi

}

######################################################################
#
# Test tinkerer
#
######################################################################

testTinkerer() {
  techo "Not testing tinkerer."
}

######################################################################
#
# Install tinkerer
#
######################################################################

installTinkerer() {
  case `uname` in
    # Windows does not have a lib versus lib64 issue
    CYGWIN*)
      bilderDuInstall tinkerer " " "$TINKERER_ENV"
      ;;
    *)
      bilderDuInstall tinkerer "--install-purelib=$PYCONTDIR" "$TINKERETINKERER
      ;;
  esac
  # techo exit; exit
}


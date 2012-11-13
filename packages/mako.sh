#!/bin/bash
#
# Version and build information for mako
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

MAKO_BLDRVERSION=${MAKO_BLDRVERSION:-"0.3.6"}

######################################################################
#
# Other values
#
######################################################################

MAKO_BUILDS=${MAKO_BUILDS:-"cc4py"}
MAKO_DEPS=Python,setuptools
MAKO_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/bin
addtopathvar PATH $BLDR_INSTALL_DIR/bin

#####################################################################
#
# Launch mako builds.
#
######################################################################

buildMako() {

  if bilderUnpack Mako; then
# Remove all old installations
    cmd="rmall ${PYTHON_SITEPKGSDIR}/Mako*"
    techo "$cmd"
    $cmd

# Build away
    MAKO_ENV="$DISTUTILS_ENV"
    decho MAKO_ENV = $MAKO_ENV
    bilderDuBuild -p mako Mako '-' "$MAKO_ENV"
  fi

}

######################################################################
#
# Test mako
#
######################################################################

testMako() {
  techo "Not testing Mako."
}

######################################################################
#
# Install mako
#
######################################################################

installMako() {
  case `uname` in
    # Windows does not have a lib versus lib64 issue
    CYGWIN*)
      bilderDuInstall -p mako Mako " " "$MAKO_ENV"
      ;;
    *)
      bilderDuInstall -p mako Mako "--install-purelib=$PYTHON_SITEPKGSDIR" "$MAKO_ENV"
      ;;
  esac
}

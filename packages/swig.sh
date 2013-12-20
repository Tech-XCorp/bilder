#!/bin/bash
#
# Version and build information for swig
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SWIG_BLDRVERSION_STD=2.0.4
SWIG_BLDRVERSION_EXP=2.0.11

######################################################################
#
# Builds, deps, mask, auxdata, paths, builds of other packages
#
######################################################################

SWIG_BUILDS=${SWIG_BUILDS:-"ser"}
SWIG_DEPS=pcre

######################################################################
#
# Add to path
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/swig/bin

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
  # techo exit; exit
}


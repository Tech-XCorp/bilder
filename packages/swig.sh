#!/bin/bash
#
# Version and build information for swig
#
# $Id: swig.sh 5209 2012-02-09 23:23:28Z dws $
#
######################################################################

######################################################################
#
# Version
#
######################################################################

SWIG_BLDRVERSION=${SWIG_BLDRVERSION:-"2.0.4"}

######################################################################
#
# Other values
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
  if bilderUnpack swig; then
    if bilderConfig swig ser; then
      case `uname` in
        Linux) # Fix rpath
          local SWIG_MAKE_ENV=LD_RUN_PATH=`(cd $CONTRIB_DIR/pcre/lib; pwd -P)`
          ;;
      esac
      bilderBuild swig ser "$SWIG_MAKE_ENV"
    fi
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


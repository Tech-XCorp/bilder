#!/bin/bash
#
# Version and build information for metatau
#
# $Id$
#
######################################################################

######################################################################
#
# Version
#
######################################################################

METATAU_BLDRVERSION=${METATAU_BLDRVERSION:-"2.21.1"}

######################################################################
#
# Other values
#
######################################################################

METATAU_BUILDS=${METATAU_BUILDS:-"par"}
METATAU_DEPS=openmpi
METATAU_UMASK=002

######################################################################
#
# Add to paths
#
######################################################################

addtopathvar PATH $CONTRIB_DIR/tau/bin

######################################################################
#
# Launch metatau builds.
#
######################################################################

buildMetatau() {
  if bilderUnpack metatau; then
    bilderConfig $LD_RUN_FLAG metatau par "$METATAU_PAR_OTHER_ARGS"
    export TAU_METATAU_MAKEJ_ARGS=$METATAU_MAKEJ_ARGS
    bilderBuild metatau par $LD_RUN_VAR
  fi
}

######################################################################
#
# Test metatau
#
######################################################################

testMetatau() {
  techo "Not testing metatau."
}

######################################################################
#
# Install metatau
#
######################################################################

installMetatau() {
  if bilderInstall $LD_RUN_FLAG metatau par tau; then
# Fix up bad tau installation
    xmmfiledir="$CONTRIB_DIR/metatau-${METATAU_BLDRVERSION}-par/pdtoolkit-*/include/kai/fix"
    cd $xmmfiledir
    if test ! -f xmmintrin.h; then
      techo "$xmmfiledir/xmmintrin.h does not exist.  Creating empty file."
      touch xmmintrin.h
    fi
    cd -
  fi
}


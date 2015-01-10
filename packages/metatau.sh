#!/bin/bash
#
# Version and build information for metatau
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in metatau_aux.sh
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/metatau_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value change
# here do not, so that build gets triggered by change of this file.
# E.g: mask
#
######################################################################

setMetatauNonTriggerVars() {
  METATAU_UMASK=002
}
setMetatauNonTriggerVars

######################################################################
#
# Launch builds
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
# Test
#
######################################################################

testMetatau() {
  techo "Not testing metatau."
}

######################################################################
#
# Install
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


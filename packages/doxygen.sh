#!/bin/bash
#
# Version and build information for doxygen
#
# $Id$
#
######################################################################

######################################################################
#
# Trigger variables set in aux script
#
######################################################################

mydir=`dirname $BASH_SOURCE`
source $mydir/doxygen_aux.sh

######################################################################
#
# Set variables that should trigger a rebuild, but which by value
# change here do not, so that build gets triggered by change of this
# file. E.g: mask
#
######################################################################

setDoxygenNonTriggerVars() {
  :
}
setDoxygenNonTriggerVars

######################################################################
#
# Launch doxygen builds.
#
######################################################################

buildDoxygen() {
# Determine whether inplace, using cmake ...
  computeVersion doxygen
  local DVERREL=`echo $DOXYGEN_BLDRVERSION | sed -e 's/^.*\.//'`
  techo "DVERREL = $DVERREL."
  if test $DVERREL -lt 10; then
    DOXYGEN_INPLACE=-i
    local DOXYGEN_NOCONFIG=-n
  else
    DOXYGEN_INPLACE=
    local DOXYGEN_CONFIG_ARGS="$CMAKE_COMPILERS_PYC $CMAKE_COMPFLAGS_PYC"
  fi
# Unpack
  if ! bilderUnpack $DOXYGEN_INPLACE doxygen; then
    return
  fi
# Build
  if bilderConfig $DOXYGEN_INPLACE $DOXYGEN_NOCONFIG doxygen $FORPYTHON_STATIC_BUILD "$DOXYGEN_CONFIG_ARGS"; then
    bilderBuild doxygen $FORPYTHON_STATIC_BUILD
  fi
}

######################################################################
#
# Test doxygen
#
######################################################################

testDoxygen() {
  techo "Not testing doxygen."
}

######################################################################
#
# Install doxygen
#
######################################################################

installDoxygen() {
  if bilderInstall -p open doxygen $FORPYTHON_STATIC_BUILD "" "$DOXYGEN_INPLACE"; then
    mkdir -p $CONTRIB_DIR/bin
    local instsfx=
    test $FORPYTHON_STATIC_BUILD != ser && instsfx="-${FORPYTHON_STATIC_BUILD}"
    (cd $CONTRIB_DIR/bin; rm -f doxygen; ln -s ../doxygen${instsfx}/bin/doxygen .)
  fi
}


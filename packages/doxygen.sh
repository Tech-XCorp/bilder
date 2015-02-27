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

#setDoxygenNonTriggerVars() {
#  :
#}
#setDoxygenNonTriggerVars

######################################################################
#
# Launch doxygen builds.
#
######################################################################

buildDoxygen() {
  if ! bilderUnpack -i doxygen; then
    return
  fi
  if bilderConfig -i -n doxygen $FORPYTHON_STATIC_BUILD; then
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
  if bilderInstall -p open doxygen $FORPYTHON_STATIC_BUILD "" "-i"; then
    mkdir -p $CONTRIB_DIR/bin
    local instsfx=
    test $FORPYTHON_STATIC_BUILD != ser && instsfx=$FORPYTHON_STATIC_BUILD
    (cd $CONTRIB_DIR/bin; rm -f doxygen; ln -s ../doxygen-$instsfx/bin/doxygen .)
  fi
}


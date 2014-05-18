#!/bin/bash
#
# Trigger vars and find information
#
# $Id$
#
######################################################################

######################################################################
#
# Set variables whose change should not trigger a rebuild or will
# by value change trigger a rebuild, as change of this file will not
# trigger a rebuild.
# E.g: version, builds, deps, auxdata, paths, builds of other packages
#
######################################################################

setZlibTriggerVars() {
  ZLIB_BLDRVERSION=${ZLIB_BLDRVERSION:-"1.2.6"}
  if test -z "$ZLIB_BUILDS"; then
# zlib needed only on windows
    if [[ `uname` =~ CYGWIN ]]; then
      ZLIB_DESIRED_BUILDS=${ZLIB_DESIRED_BUILDS:-"ser,sersh,sermd"}
      computeBuilds zlib
      addCc4pyBuild zlib
    fi
  fi
  ZLIB_DEPS=cmake
}

######################################################################
#
# Find zlib
#
######################################################################

findZlib() {
# This is needed for Windows to get the right dll
  addtopathvar PATH $CONTRIB_DIR/zlib-${FORPYTHON_BUILD}/bin
}

